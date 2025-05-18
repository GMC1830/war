#!/bin/bash

set -e  # Завершить выполнение скрипта при первой ошибке

# Функция для обработки ошибок
handle_error() {
    echo "Ошибка на строке $1"
    exit 1
}
trap 'handle_error $LINENO' ERR

# Обновление пакетов и установка chrony
apt-get update && apt-get install -y chrony || { echo "Ошибка установки chrony"; exit 1; }

# Конфигурация chrony
cat <<'EOF' > /etc/chrony.conf
server 192.168.5.1 iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
logdir /var/log/chrony
EOF

systemctl enable --now chronyd || { echo "Ошибка активации chronyd"; exit 1; }

# Удаление bind и установка samba
apt-get update && apt-get remove -y bind || { echo "Ошибка удаления bind"; exit 1; }
apt-get install -y samba samba-client task-samba-dc || { echo "Ошибка установки samba"; exit 1; }

# Резервное копирование конфигурационного файла Samba
mv /etc/samba/smb.conf /etc/samba/smb.conf.bak || { echo "Ошибка резервного копирования smb.conf"; exit 1; }

# Настройка Samba Domain Controller
samba-tool domain provision --realm=AU-TEAM.IRPO --domain=AU-TEAM --server-role=dc --dns-backend=SAMBA_INTERNAL --use-rfc2307 --adminpass='P@ssw0rd' || { echo "Ошибка настройки Samba DC"; exit 1; }

cp -f /var/lib/samba/private/krb5.conf /etc/krb5.conf || { echo "Ошибка копирования krb5.conf"; exit 1; }

# Настройка resolv.conf
mkdir -p /etc/net/ifaces/ens19 || { echo "Ошибка создания директории ens19"; exit 1; }
cat <<'EOF' > /etc/net/ifaces/ens19/resolv.conf
search au-team.irpo
nameserver 127.0.0.1
EOF

resolvconf -u || { echo "Ошибка обновления resolvconf"; exit 1; }
systemctl restart network || { echo "Ошибка перезапуска сети"; exit 1; }
systemctl enable --now samba || { echo "Ошибка активации samba"; exit 1; }

# Настройка cron для перезапуска сервисов
cat << EOF > /tmp/crontab.tmp
@reboot sleep 45 ; /bin/systemctl restart network
@reboot sleep 60 ; /bin/systemctl restart samba
EOF

crontab /tmp/crontab.tmp && rm -f /tmp/crontab.tmp || { echo "Ошибка установки crontab"; exit 1; }

# Установка утилит для BIND
apt-get update && apt-get install -y bind-utils || { echo "Ошибка установки bind-utils"; exit 1; }

# Аутентификация администратора
kinit administrator@AU-TEAM.IRPO || { echo "Ошибка аутентификации администратора"; exit 1; }

# Создание пользователей в Samba
bash << 'EOF'
echo ">>> Создание пользователей user1.hq - user5.hq..."
for i in {1..5}; do
  samba-tool user create "user${i}.hq" 'P@ssw0rdHQ' --given-name=User --surname="${i}HQ" || echo "Предупреждение: Ошибка создания user${i}.hq"
done
echo "<<< Пользователи созданы."
EOF

samba-tool group add hq || { echo "Ошибка добавления группы hq"; exit 1; }
samba-tool group addmembers hq user1.hq,user2.hq,user3.hq,user4.hq,user5.hq || { echo "Ошибка добавления пользователей в группу hq"; exit 1; }

# Скрипт для импорта пользователей из CSV файла
cat << 'EOF' > /root/samba_user_add.sh
#!/bin/bash
CSV_FILE="/opt/users.csv"
if [ ! -f "$CSV_FILE" ]; then echo "Ошибка: Файл $CSV_FILE не найден!"; exit 1; fi
echo ">>> Начало импорта пользователей из $CSV_FILE..."
tail -n +2 "$CSV_FILE" | while IFS=';' read -r first_name last_name role phone ou street zip city country password; do
    first_name=$(echo "${first_name}" | tr -d '\r')
    last_name=$(echo "${last_name}" | tr -d '\r')
    user_name="${first_name,,}.${last_name,,}"
    if [[ -z "$user_name" || "$user_name" == "." ]]; then continue; fi
    echo -n "Обработка: $user_name ... "
    samba-tool user add "$user_name" 'P@ssw0rd1'
    if [ $? -ne 0 ]; then
      echo "Предупреждение: Ошибка добавления $user_name (возможно, уже существует)."
    else
      echo "Добавлен."
    fi
done
echo "<<< Импорт пользователей завершён."
EOF

chmod +x /root/samba_user_add.sh || { echo "Ошибка установки прав на samba_user_add.sh"; exit 1; }
#/root/samba_user_add.sh

# Настройка SSH

sed -i 's/^#*[[:space:]]*Port[[:space:]]+.*/Port 2024/' /etc/openssh/sshd_config || { echo "Ошибка изменения порта SSH"; exit 1; }
systemctl restart sshd || { echo "Ошибка перезапуска sshd"; exit 1; }

# Установка Ansible
apt-get update && apt-get install -y ansible || { echo "Ошибка установки Ansible"; exit 1; }

# Генерация SSH ключей и копирование их на удаленные серверы
ssh-keygen -t rsa -f /root/.ssh/id_rsa -N "" || echo "Ключ уже существует."
ssh-copy-id -i /root/.ssh/id_rsa.pub -p 2024 sshuser@192.168.1.10 || { echo "Ошибка копирования SSH ключа на 192.168.1.10"; exit 1; }
ssh-copy-id -i /root/.ssh/id_rsa.pub user@192.168.2.10 || { echo "Ошибка копирования SSH ключа на 192.168.2.10"; exit 1; }
ssh-copy-id -i /root/.ssh/id_rsa.pub net_admin@172.16.4.4 || { echo "Ошибка копирования SSH ключа на 172.16.4.4"; exit 1; }
ssh-copy-id -i /root/.ssh/id_rsa.pub net_admin@172.16.5.5 || { echo "Ошибка копирования SSH ключа на 172.16.5.5"; exit 1; }

# Настройка Ansible
mkdir -p /etc/ansible || { echo "Ошибка создания директории Ansible"; exit 1; }
cat <<'EOF' > /etc/ansible/hosts
[hq]
192.168.1.10 ansible_user=sshuser ansible_port=2024
192.168.2.10 ansible_user=user
172.16.4.4 ansible_user=net_admin

[br]
172.16.5.5 ansible_user=net_admin
192.168.3.10 ansible_user=sshuser ansible_port=2024
EOF

cat <<'EOF' > /etc/ansible/ansible.cfg
[defaults]
inventory      = /etc/ansible/hosts
host_key_checking = False
interpreter_python = auto_silent
EOF

echo "Скрипт выполнен успешно."

apt-get update && apt-get install -y docker-engine docker-compose
systemctl enable --now docker
docker volume create dbvolume
cat << 'EOF' > /home/sshuser/wiki.yml
version: '3.7'
services:
  mediawiki:
    container_name: wiki
    image: mediawiki
    restart: always
    ports:
      - "8080:80"
    links:
      - mariadb:mariadb
    volumes:
      - images:/var/www/html/images
      # - ./LocalSettings.php:/var/www/html/LocalSettings.php
    depends_on:
      - mariadb
  mariadb:
    container_name: mariadb
    image: mariadb
    restart: always
    environment:
      MYSQL_DATABASE: mediawiki
      MYSQL_USER: wiki
      MYSQL_PASSWORD: WikiP@ssword
      MYSQL_RANDOM_ROOT_PASSWORD: 'yes'
    volumes:
      - dbvolume:/var/lib/mysql
volumes:
  images: {}
  dbvolume:
    external: true
EOF
chown sshuser:sshuser /home/sshuser/wiki.yml
systemctl stop docker && sleep 5 && systemctl start docker && sleep 10
docker compose -f /home/sshuser/wiki.yml up -d


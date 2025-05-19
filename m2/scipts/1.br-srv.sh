#!/bin/bash

# Установка и настройка chrony
apt-get update && apt-get install -y chrony
cat << 'EOF' > /etc/chrony.conf
server 192.168.5.1 iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
logdir /var/log/chrony
EOF
systemctl enable --now chronyd

# Удаление bind и установка samba
apt-get update && apt-get remove -y bind && apt-get install -y samba samba-client task-samba-dc

# Резервное копирование конфигурационного файла Samba
mv /etc/samba/smb.conf /etc/samba/smb.conf.bak

# Настройка Samba Domain Controller
samba-tool domain provision --realm=AU-TEAM.IRPO --domain=AU-TEAM --server-role=dc --dns-backend=SAMBA_INTERNAL --use-rfc2307 --adminpass='P@ssw0rd' --option="dns forwarder = 192.168.1.10"
cp -f /var/lib/samba/private/krb5.conf /etc/krb5.conf

# Настройка resolv.conf
mkdir -p /etc/net/ifaces/ens19
cat << 'EOF' > /etc/net/ifaces/ens19/resolv.conf
search au-team.irpo
nameserver 127.0.0.1
EOF
resolvconf -u
systemctl restart network
systemctl enable --now samba

# Настройка cron для перезапуска сервисов при загрузке
cat << EOF > /tmp/crontab.tmp
@reboot sleep 45 ; /bin/systemctl restart network
@reboot sleep 60 ; /bin/systemctl restart samba
EOF
crontab /tmp/crontab.tmp && rm -f /tmp/crontab.tmp

# Установка утилит для BIND
apt-get update && apt-get install -y bind-utils

# Аутентификация администратора
kinit administrator@AU-TEAM.IRPO

# Создание пользователей user1.hq - user5.hq
echo ">>> Создание пользователей user1.hq - user5.hq..."
for i in {1..5}; do
    samba-tool user create "user${i}.hq" 'P@ssw0rdHQ' --given-name=User --surname="${i}HQ" || echo "Предупреждение: Ошибка создания user${i}.hq"
done
echo "<<< Пользователи созданы."

# Создание группы и добавление пользователей в группу
samba-tool group add hq
samba-tool group addmembers hq user1.hq,user2.hq,user3.hq,user4.hq,user5.hq

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

chmod +x /root/samba_user_add.sh
/root/samba_user_add.sh

# Изменение порта SSH, 

sudo sed -i '/^#*Port / s/[0-9]\+/2024/' /etc/openssh/sshd_config

echo "Port 2024" | sudo tee -a /etc/openssh/sshd_config

systemctl restart sshd

# Установка Ansible
apt-get update && apt-get install -y ansible

# Генерация SSH ключей и копирование их на удаленные серверы
ssh-keygen -t rsa -f /root/.ssh/id_rsa -N "" || echo "Ключ уже существует."
ssh-copy-id -i /root/.ssh/id_rsa.pub -p 2024 sshuser@192.168.1.10
ssh-copy-id -i /root/.ssh/id_rsa.pub user@192.168.2.10
ssh-copy-id -i /root/.ssh/id_rsa.pub net_admin@172.16.4.4
ssh-copy-id -i /root/.ssh/id_rsa.pub net_admin@172.16.5.5
ssh-copy-id -i /root/.ssh/id_rsa.pub -p 2024 sshuser@192.168.3.10

# Настройка Ansible инвентаря и конфигурации
mkdir -p /etc/ansible
cat << 'EOF' > /etc/ansible/hosts
[hq]
192.168.1.10 ansible_user=sshuser ansible_port=2024
192.168.2.10 ansible_user=user
172.16.4.4 ansible_user=net_admin

[br]
172.16.5.5 ansible_user=net_admin
192.168.3.10 ansible_user=sshuser ansible_port=2024
EOF

cat << 'EOF' > /etc/ansible/ansible.cfg
[defaults]
inventory      = /etc/ansible/hosts
host_key_checking = False
interpreter_python = auto_silent
EOF

echo "Скрипт выполнен успешно."

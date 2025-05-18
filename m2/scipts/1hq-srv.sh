#!/bin/bash

# Обновление пакетов и установка chrony, если он еще не установлен
if ! dpkg -l | grep -q chrony; then
    apt-get update && apt-get install -y chrony
fi

# Конфигурация chrony, если файл конфигурации еще не существует
if [ ! -f /etc/chrony.conf.bak ]; then
    cp /etc/chrony.conf /etc/chrony.conf.bak  # Создаем резервную копию
    cat <<'EOF' > /etc/chrony.conf
server 192.168.1.1 iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
logdir /var/log/chrony
EOF
fi

# Включение и запуск chronyd, если он еще не запущен
if ! systemctl is-active --quiet chronyd; then
    systemctl enable --now chronyd
fi

# Добавление сервера в конфигурацию dnsmasq, если он еще не добавлен
if ! grep -q 'server=/au-team.irpo/192.168.3.10' /etc/dnsmasq.conf; then
    echo "server=/au-team.irpo/192.168.3.10" | tee -a /etc/dnsmasq.conf > /dev/null
    systemctl restart dnsmasq
fi

# Установка mdadm и fdisk, если они еще не установлены
if ! dpkg -l | grep -q mdadm; then
    apt-get update && apt-get install -y mdadm fdisk
fi

# Создание RAID, если он еще не создан
if ! mdadm --detail /dev/md0 &>/dev/null; then
    read -p "RAID не создан. Создать RAID 5 на /dev/sdb, /dev/sdc и /dev/sdd? (y/n): " create_raid
    if [[ "$create_raid" == "y" ]]; then
        mdadm --create /dev/md0 --level=5 --raid-devices=3 /dev/sdb /dev/sdc /dev/sdd --force
        mkdir -p /etc/mdadm
        mdadm --detail --scan --verbose >> /etc/mdadm/mdadm.conf
        cp /etc/mdadm/mdadm.conf /etc/mdadm.conf 2>/dev/null || true

        # Создание раздела на RAID и файловой системы, если еще не сделано
        if ! fdisk -l | grep -q '/dev/md0p1'; then
            fdisk /dev/md0 <<EOF
n
p
1


w
EOF
            mkfs.ext4 /dev/md0p1
        fi

        # Добавление в fstab, если еще не добавлено
        if ! grep -q "/raid5" /etc/fstab; then
            mkdir -p /raid5
            raid_uuid=$(blkid -s UUID -o value /dev/md0p1)
            echo "UUID=$raid_uuid /raid5 ext4 defaults 0 2" >> /etc/fstab
            mount -a
        fi
    else
        echo "Создание RAID отменено."
    fi
fi

# Установка NFS сервера, если он еще не установлен
if ! dpkg -l | grep -q nfs-server; then
    apt-get update && apt-get install -y nfs-server
fi

# Настройка NFS, если директория еще не создана
if [ ! -d /raid5/nfs ]; then
    read -p "Директория NFS не найдена. Создать /raid5/nfs? (y/n): " create_nfs_dir
    if [[ "$create_nfs_dir" == "y" ]]; then
        mkdir -p /raid5/nfs
        chown 99:99 /raid5/nfs
        chmod 777 /raid5/nfs

        cat <<'EOF' > /etc/exports
/raid5/nfs 192.168.2.0/28(rw,sync,no_subtree_check)
EOF

        exportfs -ra
        systemctl enable --now nfs-server
    else
        echo "Создание директории NFS отменено."
    fi
fi

# Изменение порта SSH, если это еще не сделано
if ! grep -q '^Port[[:space:]]*2024' /etc/openssh/sshd_config; then
    read -p "Порт SSH не изменен на 2024. Изменить? (y/n): " change_ssh_port
    if [[ "$change_ssh_port" == "y" ]]; then
        sed -i 's/^#*[[:space:]]*Port[[:space:]]+.*/Port 2024/' /etc/openssh/sshd_config
        systemctl restart sshd
    else
        echo "Изменение порта SSH отменено."
    fi
fi

# Установка необходимых пакетов для Moodle, если они еще не установлены
if ! dpkg -l | grep -q apache2; then
    apt-get update && apt-get install -y apache2 mariadb-server php8.2 
        apache2-mod_php8.2 php8.2-gd php8.2-curl php8.2-intl 
        php8.2-mysqli php8.2-xml php8.2-xmlrpc php8.2-zip 
        php8.2-soap php8.2-mbstring php8.2-opcache php8.2-json 
        php8.2-ldap php8.2-xmlreader php8.2-fileinfo php8.2-sodium unzip expect
    
    systemctl enable --now httpd2.service mysqld.service
    

    # Запуск mysql_secure_installation и ожидание ввода от пользователя

    echo "Запуск mysql_secure_installation... Пожалуйста, следуйте инструкциям."

    mysql_secure_installation
    
    # Настройка базы данных Moodle, если база данных еще не создана
    if ! mysql -u root -p'P@ssw0rd' -e "USE moodledb"; then
        mysql -u root -p'P@ssw0rd' <<EOF
CREATE DATABASE IF NOT EXISTS moodledb DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'moodle'@'localhost' IDENTIFIED BY 'P@ssw0rd';
GRANT ALL PRIVILEGES ON moodledb.* TO 'moodle'@'localhost';
FLUSH PRIVILEGES;
EOF
    fi
    
    # Загрузка Moodle, если директория еще не создана или файл отсутствует
    if [ ! -d /var/www/html/moodle ]; then
        read -p "Директория Moodle не найдена. Загрузить Moodle? (y/n): " download_moodle
        if [[ "$download_moodle" == "y" ]]; then
            curl -L https://download.moodle.org/download.php/direct/stable405/moodle-4.5.4.zip -o /tmp/moodle.zip
            
            rm -f /var/www/html/index.html
            
            unzip /tmp/moodle.zip -d /var/www/html
            
            mv /var/www/html/moodle/* /var/www/html/
            chown -R apache2:apache2 /var/www/html
            
            mkdir /var/www/moodledata || true  # Игнорируем ошибку, если директория уже существует
            
            chown apache2:apache2 /var/www/moodledata || true  # Игнорируем ошибку, если директория уже существует
            
            chmod 770 /var/www/moodledata
            
            PHP_INI_FILE="/etc/php/8.2/apache2-mod_php/php.ini"
            
            sed -i 's/^[[:space:]]*;[[:space:]]*max_input_vars[[:space:]]*=.*$/max_input_vars = 1000/' "$PHP_INI_FILE"
            sed -i 's/^[[:space:]]*max_input_vars[[:space:]]*=.*$/max_input_vars = 5000/' "$PHP_INI_FILE"
            
            systemctl restart httpd2.service
            
            # Настройка конфигурации Moodle, если файл конфигурации уже существует.
            MOODLE_CONFIG="/var/www/html/config.php"
            if [ -f "$MOODLE_CONFIG" ]; then 
                PUBLIC_WWWROOT="http://moodle.au-team.irpo"
                sed -i "s#^$CFG->wwwroots*=s*'.*';#$CFG->wwwroot = '$PUBLIC_WWWROOT';#" "$MOODLE_CONFIG"
            fi 
        else
            echo "Загрузка Moodle отменена."
        fi 
    fi 
fi 


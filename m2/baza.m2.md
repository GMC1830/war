## HQ-RTR

apt-get update && apt-get install -y wget

wget https://raw.githubusercontent.com/GMC1830/war/refs/heads/main/m2/scipts/1hq-rtr.sh

chmod +x ./1hq-rtr.sh

./1hq-rtr.sh

## BR-RTR

apt-get update && apt-get install -y wget

wget https://raw.githubusercontent.com/GMC1830/war/refs/heads/main/m2/scipts/1br-rtr.sh

chmod +x ./1br-rtr.sh

./1br-rtr.sh

## HQ-SRV

apt-get update && apt-get install -y wget

wget https://raw.githubusercontent.com/GMC1830/war/refs/heads/main/m2/scipts/hq-srv.sh

chmod +x ./hq-srv.sh

./hq-srv.sh

>> for Moodle >> on hq-srv

apt-get install -y apache2 php8.2 apache2-mod_php8.2 mariadb-server
php8.2-opcache php8.2-curl php8.2-gd php8.2-intl php8.2-mysqli
php8.2-xml php8.2-xmlrpc php8.2-ldap php8.2-zip php8.2-soap
php8.2-mbstring php8.2-json php8.2-xmlreader php8.2-fileinfo
php8.2-sodium php8.2-exif wget nano

-----------------------------------------------------------------------------------------

systemctl enable --now httpd2 mysqld mariadb

-----------------------------------------------------------------------------------------

wget https://raw.githubusercontent.com/GMC1830/war/refs/heads/main/m2/moodle/1.sh

chmod +x ./1.sh

./1.sh

-----------------------------------------------------------------------------------------

wget https://raw.githubusercontent.com/GMC1830/war/refs/heads/main/m2/moodle/2.sh

chmod +x ./2.sh

./2.sh

-----------------------------------------------------------------------------------------

wget https://raw.githubusercontent.com/GMC1830/war/refs/heads/main/m2/moodle/3.sh

chmod +x ./3.sh

./3.sh

-----------------------------------------------------------------------------------------

На hq-cli переходим по 192.168.1.10/moodle/install.php

тип бд maria

название бд moodledb

пользователь moodle

пароль P@ssw0rd

## HQ-CLI

systemctl restart sshd

epm update

epm -y install yandex-browser-stable &

apt-get update && apt-get install -y chrony

cat <<'EOF' > /etc/chrony.conf

server 192.168.2.1 iburst

driftfile /var/lib/chrony/drift

makestep 1.0 3

rtcsync

logdir /var/log/chrony

EOF

systemctl enable --now chronyd

chronyc burst 4/10

system-auth write ad au-team.irpo hq-cli AU-TEAM 'administrator' 'P@ssw0rd'

sleep 5

reboot

## BR-SRV

apt-get update && apt-get install -y wget

wget https://raw.githubusercontent.com/GMC1830/war/refs/heads/main/m2/scipts/1.br-srv.sh

chmod +x ./1.br-srv.sh

./1.br-srv.sh

-----------------------------------------------------------------------------------------

wget https://raw.githubusercontent.com/GMC1830/war/refs/heads/main/m2/scipts/medwiki.sh

chmod +x ./medwiki.sh

./medwiki.sh


> hq-cli  192.168.3.10:8080


Тип базы данных: MariaDB

Хост базы данных: mariadb 

(имя сервиса Docker).

Имя базы данных: mediawiki 

Пользователь базы данных: wiki 

Пароль пользователя базы данных: WikiP@ssword

Установите флажок "Использовать ту же учётную запись, что и для установки".

Нажмите "Continue".

Название и учётная запись:

Название вики: Wiki 

Имя пользователя (администратора): wikiadmin.

Пароль: WikiP@ssword.

Адрес email: admin@example.com 

Выберите "Хватит уже, просто установите вики".

scp -P 2024 /home/user/Downloads/LocalSettings.php sshuser@192.168.3.10:/home/sshuser/


## BR-SRV

sed -i 's/^\([[:space:]]*\)# - \(\.\/LocalSettings\.php:.*\)$/\1- \2/' /home/sshuser/wiki.yml

docker compose -f /home/sshuser/wiki.yml stop

docker compose -f /home/sshuser/wiki.yml up -d


## HQ-CLI

wget https://raw.githubusercontent.com/GMC1830/war/refs/heads/main/m2/scipts/2hq-cli.sh

chmod +x ./2hq-cli.sh

./2hq-cli.sh




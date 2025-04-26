Moodle

На hq-srv устанавливаем сервис с бд (moodle + mariabd)

apt-get update

apt-get install -y apache2 php8.2 apache2-mod_php8.2 mariadb-server \
php8.2-opcache php8.2-curl php8.2-gd php8.2-intl php8.2-mysqli \
php8.2-xml php8.2-xmlrpc php8.2-ldap php8.2-zip php8.2-soap \
 php8.2-mbstring php8.2-json php8.2-xmlreader php8.2-fileinfo \
php8.2-sodium php8.2-exif wget nano wget

systemctl enable --now httpd2 mysqld mariadb

wget https://raw.githubusercontent.com/GMC1830/war/refs/heads/main/m2/moodle/1.sh

chmod +x ./1.sh

./1.sh

wget https://github.com/GMC1830/war/blob/main/m2/moodle/2.sh

chmod +x ./2.sh

./2.sh

wget https://raw.githubusercontent.com/GMC1830/war/refs/heads/main/m2/moodle/3.sh

chmod +x ./3.sh

./3.sh

## На hq-cli переходим по 192.168.1.10/moodle/install.php



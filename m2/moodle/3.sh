# Скачивание последней стабильной версии Moodle
wget https://download.moodle.org/download.php/direct/stable405/moodle-4.5.3.tgz

# Распаковка архива
tar -zxvf moodle-4.5.3.tgz

# Перемещение папки Moodle в директорию веб-сервера
mv moodle /var/www/html

# Создание каталога для хранения данных
mkdir /var/www/moodledata

# Изменение владельца для нужных директорий
chown apache2:apache2 /var/www/html
chown apache2:apache2 /var/www/html/moodle
chown apache2:apache2 /var/www/moodledata

# Изменение параметров PHP
echo "Изменение параметров PHP..."
sed -i 's/^memory_limit = .*/memory_limit = 80M/' /etc/php/8.2/apache2-mod_php/php.ini
sed -i 's/^post_max_size = .*/post_max_size = 80M/' /etc/php/8.2/apache2-mod_php/php.ini
sed -i 's/^upload_max_filesize = .*/upload_max_filesize = 80M/' /etc/php/8.2/apache2-mod_php/php.ini
sed -i 's/; max_input_vars = [0-5000]\+/max_input_vars = 5000/' /etc/php/8.2/apache2-mod_php/php.ini

# Перезапуск Apache для применения изменений
systemctl restart httpd2


echo "ну всё типо навено..."

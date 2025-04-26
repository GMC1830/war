# Настройка базы данных для Moodle
mysql -u root -e "CREATE DATABASE moodledb;"
mysql -u root -e "CREATE USER 'moodle'@'localhost' IDENTIFIED BY 'P@ssw0rd';"
mysql -u root -e "GRANT ALL PRIVILEGES ON moodledb.* TO 'moodle'@'localhost';"
mysql -u root -e "FLUSH PRIVILEGES;"

echo "База данных moodledb и пользователь moodle успешно созданы."


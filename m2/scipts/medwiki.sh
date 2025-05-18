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

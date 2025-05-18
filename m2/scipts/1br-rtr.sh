#!/bin/bash

# Обновление пакетов и установка chrony, если он еще не установлен
if ! dpkg -l | grep -q chrony; then
    apt-get update && apt-get install -y chrony
fi

# Конфигурация chrony, если файл конфигурации еще не существует
if [ ! -f /etc/chrony.conf.bak ]; then
    cp /etc/chrony.conf /etc/chrony.conf.bak  # Создаем резервную копию
    cat <<'EOF' > /etc/chrony.conf
local stratum 5
allow 192.168.1.0/26
allow 192.168.2.0/28
allow 192.168.99.0/29
allow 192.168.3.0/27
allow 192.168.5.0/30
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

# Настройка iptables для перенаправления трафика, если правило еще не добавлено
if ! iptables -t nat -L PREROUTING | grep -q "DNAT.*192.168.1.10:2024"; then
    iptables -t nat -F PREROUTING
    iptables -t nat -A PREROUTING -i ens19 -p tcp --dport 2024 -j DNAT --to-destination 192.168.1.10:2024
    iptables-save > /etc/sysconfig/iptables
    systemctl restart iptables
fi

# Установка nginx, если он еще не установлен
if ! dpkg -l | grep -q nginx; then
    apt-get update && apt-get install -y nginx
fi

# Конфигурация nginx для Moodle, если файл конфигурации еще не существует
if [ ! -f /etc/nginx/sites-available.d/moodle.conf ]; then
    cat <<'EOF' > /etc/nginx/sites-available.d/moodle.conf
server {
    listen 80;
    server_name moodle.au-team.irpo;

    location / {
        proxy_pass http://192.168.1.10:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF
fi

# Конфигурация nginx для Wiki, если файл конфигурации еще не существует
if [ ! -f /etc/nginx/sites-available.d/wiki.conf ]; then
    cat <<'EOF' > /etc/nginx/sites-available.d/wiki.conf
server {
    listen 80;
    server_name wiki.au-team.irpo;

    location / {
        proxy_pass http://192.168.3.10:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF
fi

# Создание символьных ссылок для включения конфигураций, если они еще не созданы
if [ ! -L /etc/nginx/sites-enabled.d/moodle.conf ]; then
    ln -sf /etc/nginx/sites-available.d/moodle.conf /etc/nginx/sites-enabled.d/moodle.conf
fi

if [ ! -L /etc/nginx/sites-enabled.d/wiki.conf ]; then
    ln -sf /etc/nginx/sites-available.d/wiki.conf /etc/nginx/sites-enabled.d/wiki.conf
fi

# Проверка конфигурации nginx и перезапуск сервиса, если конфигурация не была изменена
if nginx -t; then
    systemctl enable --now nginx && systemctl restart nginx
else
    echo "Ошибка в конфигурации nginx"
fi

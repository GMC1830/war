#!/bin/bash

# Обновление пакетов и установка chrony, если он еще не установлен
if ! dpkg -l | grep -q chrony; then
    apt-get update && apt-get install -y chrony
fi

# Конфигурация chrony, если файл конфигурации еще не существует
if [ ! -f /etc/chrony.conf.bak ]; then
    cp /etc/chrony.conf /etc/chrony.conf.bak  # Создаем резервную копию
    cat <<'EOF' > /etc/chrony.conf
server 192.168.5.1 iburst
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

# Сброс правил PREROUTING в iptables, если это еще не сделано
if ! iptables -t nat -L PREROUTING | grep -q "DNAT.*192.168.3.10:8080"; then
    iptables -t nat -F PREROUTING  # Очищаем правила PREROUTING
    iptables -t nat -A PREROUTING -i ens19 -p tcp --dport 80 -j DNAT --to-destination 192.168.3.10:8080
    iptables -t nat -A PREROUTING -i ens19 -p tcp --dport 2024 -j DNAT --to-destination 192.168.3.10:2024
    iptables-save > /etc/sysconfig/iptables
    systemctl restart iptables
fi

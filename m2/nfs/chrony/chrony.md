chrony  синхра времени

chrony 

HQ-RTR

apt-get update

apt-get install chrony

/etc/chrony.conf , там мы закоментим  pool и rtsysns и доабавим своё


local stratum 5

allow 192.168.1.0/26

allow 192.168.2.0/28

allow 172.16.5.0/28

allow 192.168.4.0/27

systemctl restart chronyd

systemctl enable --now  chronyd

chronyc clients


timedatectl set-ntp 0

timedatectl

Подключение клиентов

 HQ-CLI

apt-get update

apt-get install systemd-timesyncd

Теперь зайдём в конфиг /etc/systemd/timesyncd.conf и отредактируем только одну строку, и # раскаментируем убираем #

NTP=192.168.x.x


systemctl enable --now systemd-timesyncd

systemctl restart systemd-timesyncd

timedatectl timesync-status


Настроим теперь BR-RTR, удаляем пакеты ntp, chrony, если они есть:

apt-get remove ntp

apt-2get remove  chrony


apt-get update

apt-get  install systemd-timesyncd

Настроим также его конфиг в /etc/systemd/timesyncd.conf:

NTP=172.16.4.2


systemctl enable --now systemd-timesyncd

timedatectl timesync-status

На остальных клиентах нужно проделать тоже самое, исходя из документа остались - HQ-SRV, BR-SRV (настройка идентична клиенту HQ-CLI


Но помните, что NTP для BR-SRV – это внешний IP-адрес HQ-RTR, то-есть 172.16.4.2.

hq srv  NTP=192.168.1.1

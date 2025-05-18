# war

login password > root toor

login password > user resu

## ISP

  перезапустили поосле настрройки isp reboot , а то что то не применяется, хз

apt-get update

apt-get install -y wget

wget https://raw.githubusercontent.com/GMC1830/war/refs/heads/main/m1/machine/i66.sh

chmod +x ./i66.sh

./i66.sh

## HQ-rtr

timedatectl set-timezone Asia/Vladivostok

echo 172.16.4.4/28 > /etc/net/ifaces/ens18/ipv4address 

echo default via 172.16.4.1 > /etc/net/ifaces/ens18/ipv4route

echo "TYPE=eth" > /etc/net/ifaces/ens18/options

mkdir -p /etc/net/ifaces/ens19

mkdir -p /etc/net/ifaces/gre1

mkdir -p /etc/net/ifaces/vlan100

mkdir -p /etc/net/ifaces/vlan200

mkdir -p /etc/net/ifaces/vlan999

echo -e "BOOTPROTO=static \nTYPE=eth" > /etc/net/ifaces/ens19/options

echo "10.10.0.1/30" > /etc/net/ifaces/gre1/ipv4address 

echo -e "TYPE=iptun \nTUNTYPE=gre \nTUNLOCAL=172.16.4.4 \nTUNREMOTE=172.16.5.5 \nTUNTTL=64 \nTUNOPTIONS='ttl 64' \nDISABLE=no' " > /etc/net/ifaces/gre1/options

echo 192.168.1.1/26 > /etc/net/ifaces/vlan100/ipv4address 

echo -e "TYPE=vlan \nHOST=ens19 \nVID=100" > /etc/net/ifaces/vlan100/options

echo -e "search au-team.irpo \nnameserver 192.168.1.10" > /etc/net/ifaces/vlan100/resolv.conf

echo 192.168.2.1/28 > /etc/net/ifaces/vlan200/ipv4address 

echo -e "TYPE=vlan \nHOST=ens19 \nVID=200" > /etc/net/ifaces/vlan200/options

echo 192.168.99.1/28 > /etc/net/ifaces/vlan999/ipv4address 

echo -e "TYPE=vlan \nHOST=ens19 \nVID=999" > /etc/net/ifaces/vlan999/options

sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/net/sysctl.conf

iptables -t nat -A POSTROUTING -j MASQUERADE

iptables-save >> /etc/sysconfig/iptables

systemctl enable iptables

systemctl restart iptables

service iptables restart

service iptables restart

systemctl restart network

hostnamectl set-hostname br-rtr.au-team.irpo; exec bash

## переходим в hq-srv 

timedatectl set-timezone Asia/Vladivostok

hostnamectl set-hostname hq-srv.au-team.irpo; exec bash

echo -e "BOOTPROTO=static \nTYPE=eth" > /etc/net/ifaces/ens18/options

echo 192.168.1.10/26 > /etc/net/ifaces/ens18/ipv4address 

echo "nameserver 8.8.8.8" > /etc/resolv.conf

echo default via 192.168.1.1> /etc/net/ifaces/ens18/ipv4route

systemctl restart network

apt-get update

apt-get install -y wget

wget https://raw.githubusercontent.com/GMC1830/war/refs/heads/main/m1/machine/hqsrv66DNS.sh

chmod +x ./hqsrv66DNS.sh

./hqsrv66DNS.sh

wget https://raw.githubusercontent.com/GMC1830/war/refs/heads/main/m1/machine/srv66.sh

chmod +x ./srv66.sh

./srv66.sh

wget https://raw.githubusercontent.com/GMC1830/war/refs/heads/main/m1/machine/sshdd66srv.sh

chmod +x ./sshdd66srv.sh

./sshdd66srv.sh


# на HQ-rtr

echo -e "search au-team.irpo \nnameserver 192.168.1.10" > /etc/resolv.conf

apt-get update

apt-get install -y wget

wget https://raw.githubusercontent.com/GMC1830/war/refs/heads/main/m1/machine/hq-r66.sh

chmod +x ./hq-r66.sh

./hq-r66.sh

echo -e "search au-team.irpo \nnameserver 192.168.1.10" > /etc/resolv.conf

wget https://raw.githubusercontent.com/GMC1830/war/refs/heads/main/m1/machine/rtr66.sh

chmod +x ./rtr66.sh

./rtr66.sh

echo -e "search au-team.irpo \nnameserver 192.168.1.10" > /etc/resolv.conf

wget https://raw.githubusercontent.com/GMC1830/war/refs/heads/main/m1/machine/os66.sh

chmod +x ./os66.sh

./os66.sh

echo -e "search au-team.irpo \nnameserver 192.168.1.10" > /etc/resolv.conf

## HQ-cli

timedatectl set-timezone Asia/Vladivostok

hostnamectl set-hostname hq-cli.au-team.irpo; exec bash

systemctl restart network

### проверить

тут важно , 
проверить КОМАНДОЙ  ip -c a  адресс выданный с dhcp ,

если  конец 11 , то совпадет не меняем , если нет то

меняем его в hq-srv по пути /etc/dnsmasq.conf

в строке с  "host-record=hq-cli.au-team.irpo,192.168.2.11"

смериям адресс , вписываем ИЗ hq-cli 

перезагружаем после изменения systemctl restart dnsmasq

когда ip правильный , пинговать будет по имени

## BR-rtr

timedatectl set-timezone Asia/Vladivostok

echo "172.16.5.5/28" > /etc/net/ifaces/ens18/ipv4address

echo "default via 172.16.5.1" > /etc/net/ifaces/ens18/ipv4route

echo "TYPE=eth" > /etc/net/ifaces/ens18/options

echo -e "nameserver 8.8.8.8" > /etc/resolv.conf

systemctl restart network

sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/net/sysctl.conf

iptables -t nat -A POSTROUTING -j MASQUERADE

iptables-save >> /etc/sysconfig/iptables

systemctl enable iptables

systemctl restart iptables

service iptables enable

apt-get update

apt-get install -y wget 

wget https://raw.githubusercontent.com/GMC1830/war/refs/heads/main/m1/machine/b_rt69.sh

chmod +x ./b_rt69.sh

./b_rt69.sh

wget https://raw.githubusercontent.com/GMC1830/war/refs/heads/main/m1/machine/rtr66.sh

chmod +x ./rtr66.sh

./rtr66.sh

wget https://raw.githubusercontent.com/GMC1830/war/refs/heads/main/m1/machine/osbbr66.sh

chmod +x ./osbbr66.sh

./osbbr66.sh

echo -e "search au-team.irpo \nnameserver 192.168.1.10" > /etc/resolv.conf

hostnamectl set-hostname br-rtr.au-team.irpo; exec bash

## br-srv

timedatectl set-timezone Asia/Vladivostok

hostnamectl set-hostname br-srv.au-team.irpo; exec bash

echo -e "BOOTPROTO=static \nTYPE=eth" > /etc/net/ifaces/ens18/options 

echo 192.168.3.10/27> /etc/net/ifaces/ens18/ipv4address 

echo default via 192.168.3.1> /etc/net/ifaces/ens18/ipv4route

echo -e "nameserver 8.8.8.8" > /etc/resolv.conf

systemctl restart network

apt-get update

apt-get install -y wget

wget https://raw.githubusercontent.com/GMC1830/war/refs/heads/main/m1/machine/srv66.sh

chmod +x ./srv66.sh

./srv66.sh

echo -e "search au-team.irpo \nnameserver 192.168.1.10" > /etc/resolv.conf


wget https://raw.githubusercontent.com/GMC1830/war/refs/heads/main/m1/machine/sshdd66srv.sh

chmod +x ./sshdd66srv.sh

./sshdd66srv.sh


//чистим следы

ls

rm -f NAMEFILE.SH

history -c

## на br-srv

apt-get install -y samba samba-client task-samba-dc

systemctl disable --now bind krb5kdc nmb smb slapd

mcedit /etc/hosts

192.168.3.10 br-srv.au-team.irpo


rm -f /etc/samba/smb.conf

rm -rf /var/lib/samba

rm -rf /var/cache/samba

mkdir -p /var/lib/samba

kdir /var/lib/samba/private

chmod 770 /var/lib/samba/private

samba-tool domain provision

	AU-TEAM.IRPO
	AU-TEAM
	dc
	SAMBA_INTERNAL
	192.168.1.10

P@$$w0rd
P@$$w0rd


samba-tool user add user1.hq P@ssw0rd

samba-tool user add user2.hq P@ssw0rd

samba-tool user add user3.hq P@ssw0rd

samba-tool user add user4.hq P@ssw0rd

samba-tool user add user5.hq P@ssw0rd

samba-tool group add hq

samba-tool group addmembers hq user1.hq,user2.hq,user3.hq,user4.hq,user5.hq

systemctl enable samba --now


##HQ-SRV

vim /etc/dnsmasq.conf
server=/au-team.irpo/192.168.3.10
systemctl restart dnsmasq

##hq-cli

пуск control panel authentication

2 пункт

AU-TEAM.IRPO

AU-TEAM

HQ-CLI

## br-srv

apt-repo add rpm http://altrepo.ru/local-p10 noarch local-p10

apt-get update

apt-get install -y sudo-samba-schema

sudo-schema-apply

Далее мы создаём новое правило следующей командой (которую он сам предлагает в этом окне):

create-sudo-rule

И вносим следующие изменения (имя правила можно любое):

Имя правила	: prava_hq

sudoCommand	: /bin/cat

sudoUser		: %hq



hq-cli

apt-get update

apt-get install -y admc

kinit administrator

P@$$w0rd

admc

pref ==>  advenced feat

au-team.irpo ==> sudoers ==> prava.hq ==> atributi ==> SudoOption ==> add ==> !authenticate , for SudoCommand ==> add ==> /bin/cat , /bin/grep , /usr/bin/id

apt-get update

apt-get install sudo libsss_sudo

control sudo public

Настроим конфиг sssd.conf:

mcedit /etc/sssd/sssd.conf

services = nss, pam, sudo

sudo_provider = ad

Теперь отредактируем nsswitch.conf:

mcedit /etc/nsswitch.conf

sudoers: files sss

reboot


br-srv

mcedit 11.sh


https://raw.githubusercontent.com/GMC1830/war/refs/heads/main/m2/samba/12.sh



chmod +x ./12.sh

./12.sh



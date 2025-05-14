сетевой диск

Пилим диск HQ-SRV

apt-get update

apt-get install mdadm


mdadm --create --verbose /dev/md0 -l 5 -n 3 /dev/sdc /dev/sdd /dev/sde

mdadm --detail --scan --verbose >> /etc/mdadm.conf

mkfs.ext4 /dev/md0


mkdir /raid5

mount /dev/md0 /raid5

тут

/etc/fstab

добавим строку

/dev/md0 /raid5 ext4 defaults 0 0

df -h

apt-get install nfs-utils 

apt-get install nfs-server

тут

 /etc/exports

делаем

/raid5   192.168.2.10(rw,sync,no_root_squash,no_subtree_check)

exportfs -ra 

systemctl enable --now nfs

HQ-cli
apt-get update

apt-get install nfs-utils

systemctl enable --now nfs-utils  Вроде так работает и без

mount  192.168.1.10:/raid5 /mnt

надо

/etc/fstab сюда

это 192.168.1.10:/raid5 /mnt/ nfs auto 0 0 автоматическое монтирование - работает после перезагрузки

reboot

# shellcheck disable=SC1113
#/bin/bash
yum install nfs-utils -y
systemctl start nfs
systemctl enable nfs.service
mkdir /data/v1 -p
echo "/data/v1 172.16.120.0/24(rw,no_root_squash)" >> /etc/exports
exportfs -arv
systemctl restart nfs
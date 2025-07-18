#!/bin/bash
yum update -y
yum install -y nodejs22

npm install -g --unsafe-perm node-red

useradd node-red

echo "${noderedService}" > /etc/systemd/system/nodered.service


mkdir -p /efs/nodeRed

mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_dns}:/ /efs/nodeRed

echo "${efs_dns}:/ /efs/nodeRed nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab

chown -R node-red:node-red /efs/nodeRed/

systemctl start nodered.service
systemctl enable nodered.service
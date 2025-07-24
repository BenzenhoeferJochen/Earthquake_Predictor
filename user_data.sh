#!/bin/bash
yum update -y
yum install -y nodejs22
useradd node-red

mkdir -p /efs/nodeRed

mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_dns}:/ /efs/nodeRed

echo "${efs_dns}:/ /efs/nodeRed nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab

echo "${pemFile}" > /home/ec2-user/labsuser.pem
chmod 400 /home/ec2-user/labsuser.pem

mkdir -p /efs/nodeRed/.node-red

chown -R ec2-user:ec2-user /efs/nodeRed/


touch /etc/systemd/system/refreshLab.service
touch /etc/systemd/system/refreshLab.timer
touch /usr/local/bin/refreshLab.sh

echo '${refreshLabService}' > /etc/systemd/system/refreshLab.service
echo '${refreshLabTimer}' > /etc/systemd/system/refreshLab.timer
echo "${refreshLabScript}" > /usr/local/bin/refreshLab.sh

chmod 744 /usr/local/bin/refreshLab.sh

systemctl start refreshLab.timer
systemctl enable refreshLab.timer
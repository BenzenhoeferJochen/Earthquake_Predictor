#!/bin/bash
yum update -y
yum install -y nodejs22

useradd node-red

echo "${noderedService}" > /etc/systemd/system/nodered.service

systemctl start nodered.service
systemctl enable nodered.service

mkdir -p /efs/nodeRed

mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_dns}:/ /efs/nodeRed

mkdir -p /efs/nodeRed/.node-red

if [ -f /efs/nodeRed/.node-red/Node-Red/flows.json ]; then
    chown -R ec2-user:ec2-user /efs/nodeRed/.node-red/Node-Red/flows.json
else
    chown -R ec2-user:ec2-user /efs/nodeRed/
fi
if [ -f /efs/nodeRed/.node-red/Node-Red/settings.js ]; then
    chown -R ec2-user:ec2-user /efs/nodeRed/.node-red/Node-Red/settings.js
else
    chown -R ec2-user:ec2-user /efs/nodeRed/
fi

chown ec2-user:ec2-user /efs/nodeRed/ /efs/nodeRed/.node-red /efs/nodeRed/.node-red/Node-Red

npm install -g --unsafe-perm node-red

touch /etc/systemd/system/refreshLab.service
touch /etc/systemd/system/refreshLab.timer
touch /usr/local/bin/refreshLab.sh

echo '${refreshLabService}' > /etc/systemd/system/refreshLab.service
echo '${refreshLabTimer}' > /etc/systemd/system/refreshLab.timer
echo "${refreshLabScript}" > /usr/local/bin/refreshLab.sh

chmod 744 /usr/local/bin/refreshLab.sh

systemctl start refreshLab.timer
systemctl enable refreshLab.timer
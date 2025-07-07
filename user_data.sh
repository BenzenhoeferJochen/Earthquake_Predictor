#!/bin/bash
yum update -y
yum install -y nodejs22

npm install -g --unsafe-perm node-red

useradd node-red
echo "${noderedService}" > /etc/systemd/system/nodered.service

systemctl start nodered.service
systemctl enable nodered.service

touch /etc/systemd/system/refreshLab.service
touch /etc/systemd/system/refreshLab.timer
touch /usr/local/bin/refreshLab.sh

echo '${refreshLabService}' > /etc/systemd/system/refreshLab.service
echo '${refreshLabTimer}' > /etc/systemd/system/refreshLab.timer
echo "${refreshLabScript}" > /usr/local/bin/refreshLab.sh

chmod 744 /usr/local/bin/refreshLab.sh

systemctl start refreshLab.timer
systemctl enable refreshLab.timer
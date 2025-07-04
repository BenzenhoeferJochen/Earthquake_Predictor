#!/bin/bash
yum update -y
yum install -y nodejs22

npm install -g --unsafe-perm node-red

useradd node-red
echo "${noderedService}" > /etc/systemd/system/nodered.sservice

systemctl start nodered.service
systemctl enable nodered.service
#!/bin/bash

echo "Prepairing to backup Node-Red directory..."
sudo chown -R ec2-user:ec2-user /efs/nodeRed/
echo "Starting backup of Node-Red directory..."
sudo cp -r /efs/nodeRed/.node-red/Node-Red /home/ec2-user/Node-Red-backup
sudo rm -rf /home/ec2-user/Node-Red-backup/lib
sudo rm -rf /home/ec2-user/Node-Red-backup/node_modules
sudo chown -R ec2-user:ec2-user /home/ec2-user/Node-Red-backup
echo 'Backup completed successfully.'
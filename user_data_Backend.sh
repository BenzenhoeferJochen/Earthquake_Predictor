#!/bin/bash
yum update -y

amazon-linux-extras enable mariadb10.5

yum install -y python3 python3-pip python3-virtualenv mariadb105-server gcc-c++ make pkgconfig python3-devel

touch temp.sql

echo "CREATE USER IF NOT EXISTS '${db_user}'@'%' IDENTIFIED BY '${db_password}';" >> temp.sql
echo "GRANT ALL PRIVILEGES ON ${db_database}.* TO '${db_user}'@'%';" >> temp.sql
echo "FLUSH PRIVILEGES;" >> temp.sql

mysql -p${db_password} -u root -h ${db_address} ${db_database} < temp.sql

mkdir -p /home/ec2-user/ML
echo '${database}' > /home/ec2-user/ML/database.py
echo '${earthquakeMLAPI}' > /home/ec2-user/ML/earthquake_ml_api.py
echo '${earthquakeMLRequirements}' > /home/ec2-user/ML/requirements.txt
echo '${earthquakeTimes}' > /home/ec2-user/ML/earthquake_times.py

touch /home/ec2-user/ML/__init__.py

cd /home/ec2-user/ML
python3 -m venv .venv/
source .venv/bin/activate
pip install -r requirements.txt
uvicorn earthquake_ml_api:app --host 0.0.0.0 --port 8000
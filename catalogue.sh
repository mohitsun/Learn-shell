echo -e "\e[36m>>>>>>>>>>>>> Create Catalogue service <<<<<<<<<<<<<\e[0m"
cp catalogue.service /etc/systemd/system/catalogue.service

echo -e "\e[36m>>>>>>>>>>>>> Create MongoDB repo <<<<<<<<<<<<<\e[0m"
cp mongo.repo /etc/yum.repos.d/mongo.repo

echo -e "\e[36m>>>>>>>>>>>>> Install  NodeJS repos <<<<<<<<<<<<<\e[0m"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash

echo -e "\e[36m>>>>>>>>>>>>> Install NodeJS <<<<<<<<<<<<<\e[0m"
yum install nodejs -y

echo -e "\e[36m>>>>>>>>>>>>> Create application user <<<<<<<<<<<<<\e[0m"
useradd roboshop

echo -e "\e[36m>>>>>>>>>>>>> Create application directory <<<<<<<<<<<<<\e[0m"
mkdir /app

echo -e "\e[36m>>>>>>>>>>>>> download application content <<<<<<<<<<<<<\e[0m"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip

echo -e "\e[36m>>>>>>>>>>>>> Extract application content <<<<<<<<<<<<<\e[0m"
cd /app
unzip /tmp/catalogue.zip
cd /app

echo -e "\e[36m>>>>>>>>>>>>> Download NodeJS dependencies <<<<<<<<<<<<<\e[0m"
npm install

echo -e "\e[36m>>>>>>>>>>>>> Install Mongo client <<<<<<<<<<<<<\e[0m"
yum install mongodb-org-shell -y

echo -e "\e[36m>>>>>>>>>>>>> Load catalogue schema <<<<<<<<<<<<<\e[0m"
mongo --host mongodb.mohdevops.online </app/schema/catalogue.js

echo -e "\e[36m>>>>>>>>>>>>> Start Catalogue service <<<<<<<<<<<<<\e[0m"
systemctl daemon-reload
systemctl enable catalogue
systemctl start catalogue
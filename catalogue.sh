log=/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>>>>>> Create Catalogue service <<<<<<<<<<<<<\e[0m"
cp catalogue.service /etc/systemd/system/catalogue.service &>>${log}

echo -e "\e[36m>>>>>>>>>>>>> Create MongoDB repo <<<<<<<<<<<<<\e[0m"
cp mongo.repo /etc/yum.repos.d/mongo.repo &>>${log}

echo -e "\e[36m>>>>>>>>>>>>> Install  NodeJS repos <<<<<<<<<<<<<\e[0m"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log}

echo -e "\e[36m>>>>>>>>>>>>> Install NodeJS <<<<<<<<<<<<<\e[0m"
yum install nodejs -y &>>${log}

echo -e "\e[36m>>>>>>>>>>>>> Create application user <<<<<<<<<<<<<\e[0m"
useradd roboshop &>>${log}

echo -e "\e[36m>>>>>>>>>>>>> Create application directory <<<<<<<<<<<<<\e[0m"
rm -rf /app

echo -e "\e[36m>>>>>>>>>>>>> Create application directory <<<<<<<<<<<<<\e[0m"
mkdir /app &>>${log}

echo -e "\e[36m>>>>>>>>>>>>> download application content <<<<<<<<<<<<<\e[0m"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>>${log}

echo -e "\e[36m>>>>>>>>>>>>> Extract application content <<<<<<<<<<<<<\e[0m"
cd /app
unzip /tmp/catalogue.zip &>>${log}
cd /app

echo -e "\e[36m>>>>>>>>>>>>> Download NodeJS dependencies <<<<<<<<<<<<<\e[0m"
npm install &>>${log}

echo -e "\e[36m>>>>>>>>>>>>> Install Mongo client <<<<<<<<<<<<<\e[0m"
yum install mongodb-org-shell -y &>>${log}

echo -e "\e[36m>>>>>>>>>>>>> Load catalogue schema <<<<<<<<<<<<<\e[0m"
mongo --host mongodb.mohdevops.online </app/schema/catalogue.js &>>${log}

echo -e "\e[36m>>>>>>>>>>>>> Start Catalogue service <<<<<<<<<<<<<\e[0m"
systemctl daemon-reload &>>${log}
systemctl enable catalogue &>>${log}
systemctl start catalogue &>>${log}
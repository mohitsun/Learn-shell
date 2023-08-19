log=/tmp/roboshop.log

func_apppreq(){
  echo -e "\e[36m>>>>>>>>>>>>> Create ${component} service <<<<<<<<<<<<<\e[0m"
    cp ${component}.service /etc/systemd/system/${component}.service &>>${log}

  echo -e "\e[36m>>>>>>>>>>>>> Create application user <<<<<<<<<<<<<\e[0m"
    useradd roboshop &>>${log}

    echo -e "\e[36m>>>>>>>>>>>>> cleanup existing application content <<<<<<<<<<<<<\e[0m"
    rm -rf /app &>>${log}

    echo -e "\e[36m>>>>>>>>>>>>> Create application directory <<<<<<<<<<<<<\e[0m"
    mkdir /app &>>${log}

    echo -e "\e[36m>>>>>>>>>>>>> download application content <<<<<<<<<<<<<\e[0m"
    curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log}

    echo -e "\e[36m>>>>>>>>>>>>> Extract application content <<<<<<<<<<<<<\e[0m"
    cd /app
    unzip /tmp/${component}.zip &>>${log}
    cd /app
}

func_schema_setup(){
  if [ "${schema_type}" == "mongodb" ]; then
    echo -e "\e[36m>>>>>>>>>>>>> Install Mongo client <<<<<<<<<<<<<\e[0m"
    yum install mongodb-org-shell -y &>>${log}

    echo -e "\e[36m>>>>>>>>>>>>> Load ${component} schema <<<<<<<<<<<<<\e[0m"
    mongo --host mongodb.mohdevops.online </app/schema/${component}.js &>>${log}
  fi

  if [ "${schema_type}" == "mysql" ]; then
      echo -e "\e[36m>>>>>>>>>>>>> Install mysql client<<<<<<<<<<<<<\e[0m"
      yum install mysql -y &>>${log}
      # shellcheck disable=SC2261

      echo -e "\e[36m>>>>>>>>>>>>> Load schema<<<<<<<<<<<<<\e[0m"
      mysql -h mysql.mohdevops.online -uroot -pRoboShop@1 < /app/schema/${component}.sql &>>${log}
  fi
}
func_systemd(){
     echo -e "\e[36m>>>>>>>>>>>>> Start ${component} service <<<<<<<<<<<<<\e[0m"
     systemctl daemon-reload &>>${log}
     systemctl enable ${component} &>>${log}
     systemctl start ${component} &>>${log}
}

nodejs(){
  log=/tmp/roboshop.log


  echo -e "\e[36m>>>>>>>>>>>>> Create MongoDB repo <<<<<<<<<<<<<\e[0m"
  cp mongo.repo /etc/yum.repos.d/mongo.repo &>>${log}

  echo -e "\e[36m>>>>>>>>>>>>> Install  NodeJS repos <<<<<<<<<<<<<\e[0m"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log}

  echo -e "\e[36m>>>>>>>>>>>>> Install NodeJS <<<<<<<<<<<<<\e[0m"
  yum install nodejs -y &>>${log}

  func_apppreq

  echo -e "\e[36m>>>>>>>>>>>>> Download NodeJS dependencies <<<<<<<<<<<<<\e[0m"
  npm install &>>${log}

  func_schema_setup

  func_systemd

}

func_java(){


  echo -e "\e[36m>>>>>>>>>>>>> Install maven <<<<<<<<<<<<<\e[0m"
  yum install maven -y &>>${log}

  func_apppreq

  echo -e "\e[36m>>>>>>>>>>>>> Build ${component} service <<<<<<<<<<<<<\e[0m"
  mvn clean package &>>${log}
  mv target/${component}-1.0.jar shipping.jar &>>${log}

  func_schema_setup

  func_systemd
}

func_python(){
 # cp payment.service /etc/systemd/system/payment.service
  echo -e "\e[36m>>>>>>>>>>>>> Build ${component} service <<<<<<<<<<<<<\e[0m"
  yum install python36 gcc python3-devel -y &>>${log}

  func_apppreq

  echo -e "\e[36m>>>>>>>>>>>>> Build ${component} service <<<<<<<<<<<<<\e[0m"
  pip3.6 install -r requirements.txt &>>${log}

  func_systemd
}
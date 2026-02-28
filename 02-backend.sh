#!/bin/bash

logs_folder="/var/log/Expense-shell"
script_name=$(echo $0 | cut -d "." -f1)
timestamp=$(date +%Y-%m-%d-%H-%M-%s)
log_file="$logs_folder/$script_name-$timestamp.log"
mkdir -p $logs_folder

userid=$(id -u)
R="\e[32m"
g="\e[31m"
n="\e[0m"
y="\e[33m"

check_root(){
    if [ $? -ne 0 ]
    then 
    echo -e "$R please run this script with root privileges $n" | tee -a $log_file
    exit 1
    fi
}

validate()
{
    if [ $? -ne 0 ]
    then 
    echo -e "$2 is ..$g failed $n" | tee -a $log_file
    exit 1
    else 
    echo -e "$2 is .. $R success $n" | tee -a $log_file
    fi
}
check_root

dnf module disable nodejs -y &>>log_file #disabling other nodejs verions
validate $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>log_file
validate $? "enaabling node js"

dnf install nodejs -y &>>log_file
validate $? "installing nodejs"

id expense &>>log_file
if [ $? -ne 0 ]
then 
echo "user not created..$y creating user $n " 
useradd expense &>>log_file
validate $? "creating user"
else
echo -e "user is already created ...$y skipping $n"
fi

mkdir -p /app
validate $? "creating /app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>log_ile
validate $? "dounloading backend code"

cd /app
rm -rf /app/* #  removing the existing code
unzip /tmp/backend.zip &>>log_file
validate $? "extracting the backend file"

npm install &>>log_file

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service
#validate the data beore running the backend

dnf install mysql -y &>>log_file
validate $? "donloading the database"

mysql -h 172.31.2.202 -uroot -pExpenseApp@1 < /app/schema/backend.sql
systemctl daemon-reload
validate $? "daemon reloaded"

systemctl start backend

validate $? "backend strted"

systemctl enable backend
validate $? "enbled backend"
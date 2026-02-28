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

dnf install nginx -y &>>log_file
validate $? "installing ngnix"

systemctl enable nginx &>>log_file
validate $? "enabling nginx"

systemctl start nginx &>>log_file
validate $? "started nginx"

rm -rf /usr/share/nginx/html/* &>>log_file
validate $? "removing default directory"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>log_file
validate $? "downloading front end code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>log_file
validate $? " Extracting front end code"

systemctl restart nginx &>>log_file
validate $? "restarted rontend"

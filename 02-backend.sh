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
echo "user is already created ...$R skipping $n"
fi
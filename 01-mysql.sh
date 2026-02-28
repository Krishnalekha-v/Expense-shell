#!/bin/bash

#!/bin/bash

#store the date in log files
# /var/log/shell-script/05-redirectors.sh-<timestamp>.log
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
    echo -e "$2 is ..$r failed $n" | tee -a $log_file
    exit 1
    else 
    echo -e "$2 is .. $g success $n" | tee -a $log_file
    fi
}
check_root

dnf install mysql-server -y &>>$log_file
validate $? "installing mysql server"

systemctl enable mysqld &>>$log_file
validate $? "enabled mysql server"

systemctl start mysqld &>>$log_file
validate $? "started mysql server"
mysql -h 172.31.2.202 -u root -pExpenseApp@1 -e "show database ;" &>>$log_file
if [ $? -ne 0 ]
then echo "mysql root password is not setup setting now" &>>$log_file
mysql_secure_installation --set-root-pass ExpenseApp@1
validate $? "setting up root password"
else 
echo -e "mysql root password is already setup.. $y skipping $n" | tee -a $log_file
fi  
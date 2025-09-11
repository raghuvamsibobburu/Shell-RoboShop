#!/bin/bash

USERID=$(id -u)

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"
LOGS_FOLDER="/var/log/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
PACKAGES=("mysql" "python3" "nginx" "httpd" "" "")

mkdir -p $LOGS_FOLDER
echo "Script started executing at $(date)" | tee -a $LOG_FILE

# check the user has root priveleges or not
if [ $USERID -ne 0 ]
then
    echo -e "$RED ERROR:: Please run this script with root access" $RESET | tee -a $LOG_FILE
    exit 1 #give other then 0 upto 127
else
    echo "Your running with root access" | tee -a $LOG_FILE
fi

# validate functions takes input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "Installing $2 is.......$GREEN SUCCESS $RESET" | tee -a $LOG_FILE
    else
        echo -e "Installing $2 is.......$RED FAILURE $RESET" | tee -a $LOG_FILE
        exit 1
    fi
}


dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Installing Mongodb"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling Mongodb"

dnf install redis -y  &>>$LOG_FILE
VALIDATE $? "Started Mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
VALIDATE $? "Editing MongoDB conf file for remote connections"

sed -i 's/protected-mode yes/protected-mode no/g' /etc/redis/redis.conf
VALIDATE $? "Editing MongoDB conf file for remote connections"

systemctl enable redis
VALIDATE $? "Enabled redis" 

systemctl start redis 
VALIDATE $? "Started redis"





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

dnf module disable nodejs -y
VALIDATE $? "Disabling nodeJs"

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling nodeJs version:20"

dnf install nodejs -y
VALIDATE $? "Installing nodeJs"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Creating roboshop system user"

mkdir /app 
VALIDATE $? "Creating app directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip 
VALIDATE $? "Downloading user"

rm -rf /app/*
cd /app 
unzip /tmp/user.zip
VALIDATE $? "unzipping user"

npm install
VALIDATE $? "Installing Dependencies"

systemctl daemon-reload
systemctl enable user 
systemctl start user
VALIDATE $? "Starting user"





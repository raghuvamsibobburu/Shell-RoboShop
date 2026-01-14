#!/bin/bash

START_TIME=$(date+%s)

USERID=$(id -u)

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"
LOGS_FOLDER="/var/log/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

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

dnf module disable nginx -y &>>LOG_FILE
VALIDATE $? "Disabling nodeJs"

dnf module enable nginx:1.24 -y &>>LOG_FILE
VALIDATE $? "Enabling nodeJs version:20"

dnf install nginx -y &>>LOG_FILE
VALIDATE $? "Installing nodeJs"

systemctl enable nginx &>>LOG_FILE
VALIDATE $? "Enabling nginx"

systemctl start nginx &>>LOG_FILE
VALIDATE $? "Started nginx"

rm -rf /usr/share/nginx/html/* &>>LOG_FILE
VALIDATE $? "Remove the default content that web server is serving."

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>LOG_FILE
VALIDATE $? "Download the frontend content"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>LOG_FILE
VALIDATE $? "Unziped the frontend content."

rm -rf /etc/nginx/nginx.conf &>>LOG_FILE
VALIDATE $? "Created Nginx Reverse Proxy Configuration to reach backend services."

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf 
VALIDATE $? "Copying nginx.conf"

systemctl restart nginx &>>LOG_FILE
VALIDATE $? "Restarted nginx"


END_TIME=$(date+%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script exection completed successfully, $YELLOW time taken: $TOTAL_TIME seconds $RESET" | tee -a $LOG_FILE



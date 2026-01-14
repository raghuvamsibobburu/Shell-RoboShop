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

app_setup(){
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0]
    then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
        VALIDATE $? "Creating roboshop system user"
    else
        echo -e "User already existed...$YELLOW Skipping $RESET"
    fi

    mkdir -p /app 
    VALIDATE $? "Creating app directory"

    curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip 
    VALIDATE $? "Downloading user"

    rm -rf /app/*
    cd /app 
    unzip /tmp/user.zip &>>$LOG_FILE
    VALIDATE $? "unzipping user"
}


nodejs_setup(){
    dnf module disable nodejs -y
    VALIDATE $? "Disabling nodeJs"

    dnf module enable nodejs:20 -y
    VALIDATE $? "Enabling nodeJs version:20"

    dnf install nodejs -y
    VALIDATE $? "Installing nodeJs"

    npm install
    VALIDATE $? "Installing Dependencies"
}

systemd_setup(){
    cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
    VALIDATE $? "Copying User service"

    systemctl daemon-reload
    systemctl enable user 
    systemctl start user
    VALIDATE $? "Starting user"
}

check_root(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$RED ERROR:: Please run this script with root access" $RESET | tee -a $LOG_FILE
        exit 1 #give other then 0 upto 127
    else
        echo "Your running with root access" | tee -a $LOG_FILE
    fi
}

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "Installing $2 is.......$GREEN SUCCESS $RESET" | tee -a $LOG_FILE
    else
        echo -e "Installing $2 is.......$RED FAILURE $RESET" | tee -a $LOG_FILE
        exit 1
    fi
}

print_time(){
END_TIME=$(date+%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script exection completed successfully, $YELLOW time taken: $TOTAL_TIME seconds $RESET" | tee -a $LOG_FILE
}


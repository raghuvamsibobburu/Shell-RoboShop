#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0abe24d1b55914caa"
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "payment" "dispatch" "frontend" "user" "cart" "shipping")
ZONE_ID="Z0630864SNPS171VLZQ6"
DOMAIN_NAME="buyarobot.site"

for instance in ${INSTANCES[@]}
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-0abe24d1b55914caa --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
    if [ $instance != "frontend" ]
    then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
    
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

    fi
    echo "$instance IP address: $IP"
done 

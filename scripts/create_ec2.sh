#!/bin/bash

export KEY_NAME=rafael-souza-estudos
export IMAGE_ID=ami-0d382e80be7ffdae5
export INST_TYPE=t2.micro
export QTD_INST=1
export SG_SSH_ID=$(grep -o '"GroupId": *"[^"]*"' ./configs/sg.configs | grep -o '"[^"]*"$' | sed 's/"//g')
export SBN_PUB_ID=$(grep -o '"SubnetId": *"[^"]*"' ./configs/subnet_public.configs | grep -o '"[^"]*"$' | sed 's/"//g')

aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type $INST_TYPE \
    --key-name $KEY_NAME \
    --security-group-ids $SG_SSH_ID \
    --subnet-id $SBN_PUB_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=ec2-pub-estudo}]' \
    --count $QTD_INST \
    --associate-public-ip-address > ./configs/ec2.configs
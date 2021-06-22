#!/bin/bash

aws ec2 create-security-group \
    --description acesso-SSH \
    --group-name acesso-SSH \
    --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=acesso-ssh}]' > ./configs/sg.configs

export SG_SSH_ID=$(grep -o '"GroupId": *"[^"]*"' ./configs/sg.configs | grep -o '"[^"]*"$' | sed 's/"//g')

aws ec2 authorize-security-group-ingress \
    --group-id $SG_SSH_ID \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0
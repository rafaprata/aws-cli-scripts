#!/bin/bash

#CREATE VPC COMMANDS

aws ec2 create-vpc \
    --cidr-block $VPC_CIDR \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key='$TAG_KEY',Value='$VPC_TAG'}]'  >> configs/logs
echo "Created VPC - OK"
export VPC_ID=$(aws ec2 describe-vpcs \
    --filter 'Name=tag:'$TAG_KEY',Values='$VPC_TAG'' \
     | grep -o '"VpcId": *"[^"]*"' | grep -o '"[^"]*"$' \
     | sed 's/"//g')

aws ec2 create-subnet \
    --cidr-block $SBN_PRIV_CIDR \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key='$TAG_KEY',Value='$SBN_PRIV_TAG'}]'  >> configs/logs
echo "Created Subnet Private - OK"
export SBN_PRIV_ID=$(aws ec2 describe-subnets \
    --filter 'Name=tag:'$TAG_KEY',Values='$SBN_PRIV_TAG'' \
     | grep -o '"SubnetId": *"[^"]*"' \
     | grep -o '"[^"]*"$' \
     | sed 's/"//g')

aws ec2 create-subnet \
    --cidr-block $SBN_PUB_CIDR \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key='$TAG_KEY',Value='$SBN_PUB_TAG'}]'  >> configs/logs
echo "Created Subnet Public - OK"
export SBN_PUB_ID=$(aws ec2 describe-subnets \
    --filter 'Name=tag:'$TAG_KEY',Values='$SBN_PUB_TAG'' \
     | grep -o '"SubnetId": *"[^"]*"' \
     | grep -o '"[^"]*"$' | sed 's/"//g')

aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key='$TAG_KEY',Value='$IGW_TAG'}]'  >> configs/logs
echo "Created Internet Gateway - OK"
export IGW_ID=$(aws ec2 describe-internet-gateways \
    --filter 'Name=tag:'$TAG_KEY',Values='$IGW_TAG'' \
     | grep -o '"InternetGatewayId": *"[^"]*"' \
     | grep -o '"[^"]*"$' \
     | sed 's/"//g')
aws ec2 attach-internet-gateway \
    --internet-gateway-id $IGW_ID \
    --vpc-id $VPC_ID

aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key='$TAG_KEY',Value='$RT_TAG'}]'  >> configs/logs
echo "Created Route-Table - OK"
export RT_ID=$(aws ec2 describe-route-tables \
    --filters 'Name=tag:'$TAG_KEY',Values='$RT_TAG'' \
     | grep -o '"RouteTableId": *"[^"]*"' \
     | grep -o '"[^"]*"$' \
     | sed 's/"//g')
aws ec2 create-route \
    --route-table-id $RT_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $IGW_ID  >> configs/logs
echo "Created Route - OK" 

aws ec2 associate-route-table \
    --route-table-id $RT_ID \
    --subnet-id $SBN_PUB_ID  >> configs/logs
echo "Created Route-Table Association - OK"

#CREATE SECURITY GROUPS COMMANDS

aws ec2 create-security-group \
    --description acesso-SSH \
    --group-name acesso-SSH \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=security-group,Tags=[{Key='$TAG_KEY',Value='$SG_TAG'}]' >> configs/logs
echo "Created Security Group - OK"
export SG_SSH_ID=$(aws ec2 describe-security-groups \
    --filters 'Name=tag:'$TAG_KEY',Values='$SG_TAG'' \
     | grep -o '"GroupId": *"[^"]*"' \
     | grep -o '"[^"]*"$' \
     | sed 's/"//g')

aws ec2 authorize-security-group-ingress \
    --group-id $SG_SSH_ID \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

#CREATE EC2 INSTANCES COMMANDS
aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type $INST_TYPE \
    --key-name $KEY_NAME \
    --security-group-ids $SG_SSH_ID \
    --subnet-id $SBN_PUB_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key='$TAG_KEY',Value='$EC2_TAG'}]' \
    --count $QTD_INST \
    --associate-public-ip-address >> configs/logs
echo "Created EC2 Instance - OK"
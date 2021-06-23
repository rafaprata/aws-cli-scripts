#!/bin/bash

export TAG_KEY="Name"
export VPC_CIDR="70.125.0.0/16"
export VPC_TAG="vpc-teste"
export SBN_PRIV_CIDR="70.125.1.0/24"
export SBN_PRIV_TAG="sbn-private-teste"
export SBN_PUB_CIDR="70.125.2.0/24"
export SBN_PUB_TAG="sbn-public-teste"
export IGW_TAG="igw-public-teste"
export RT_TAG="rt-teste"

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
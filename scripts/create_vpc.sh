#!/bin/bash

aws ec2 create-vpc \
    --cidr-block "70.125.0.0/16" \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=vpc-teste}]' > ./configs/vpc.configs

export VPC_ID=$(grep -o '"VpcId": *"[^"]*"' ./configs/vpc.configs | grep -o '"[^"]*"$' | sed 's/"//g')

aws ec2 create-subnet \
    --cidr-block "70.125.1.0/24" \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=sbn-private-teste}]' > ./configs/subnet_private.configs

export SBN_PRIV_ID=$(grep -o '"SubnetId": *"[^"]*"' ./configs/subnet_private.configs | grep -o '"[^"]*"$' | sed 's/"//g')

aws ec2 create-subnet \
    --cidr-block "70.125.2.0/24" \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=sbn-public-teste}]' > ./configs/subnet_public.configs

export SBN_PUB_ID=$(grep -o '"SubnetId": *"[^"]*"' ./configs/subnet_public.configs | grep -o '"[^"]*"$' | sed 's/"//g')

aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=igw-public-teste}]' > ./configs/igw.configs

export IGW_ID=$(grep -o '"InternetGatewayId": *"[^"]*"' ./configs/igw.configs | grep -o '"[^"]*"$' | sed 's/"//g')

aws ec2 attach-internet-gateway \
    --internet-gateway-id $IGW_ID \
    --vpc-id $VPC_ID

aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=rt-teste}]' > ./configs/route_table.configs

export RT_ID=$(grep -o '"RouteTableId": *"[^"]*"' ./configs/route_table.configs | grep -o '"[^"]*"$' | sed 's/"//g')

aws ec2 create-route \
    --route-table-id $RT_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $IGW_ID >> ./logs

aws ec2 associate-route-table \
    --route-table-id $RT_ID \
    --subnet-id $SBN_PUB_ID >> ./logs
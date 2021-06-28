#!/bin/bash
echo "###START DELETION SCRIPT###" >> configs/logs

aws ec2 terminate-instances \
    --instance-ids $EC2_ID >> configs/logs
echo "Delete EC2 Instance - OK"
aws ec2 delete-tags \
    --resources $EC2_ID
sleep 30

aws ec2 delete-security-group \
    --group-id $SG_SSH_ID 
echo "Delete Security Group - OK"

#aws ec2 disassociate-route-table \
#    --association-id <value>

aws ec2 delete-route-table \
    --route-table-id $RT_ID 
echo "Delete Route Table - OK"

aws ec2 detach-internet-gateway \
    --internet-gateway-id $IGW_ID \
    --vpc-id $VPC_ID

aws ec2 delete-internet-gateway \
    --internet-gateway-id $IGW_ID
echo "Delete Internet Gateway - OK"

aws ec2 delete-subnet \
    --subnet-id $SBN_PRIV_ID 
echo "Delete Private Subnet - OK"

aws ec2 delete-subnet \
    --subnet-id $SBN_PUB_ID
echo "Delete Public Subnet - OK"

aws ec2 delete-vpc \
    --vpc-id $VPC_ID 
echo "Delete VPC - OK"

echo "###FINISH DELETION SCRIPT###" >> configs/logs
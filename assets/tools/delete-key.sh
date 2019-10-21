#!/bin/bash

### Setting Keyname ###
key_name=$1

### Enumerate AWS Regions ###
regions=$(aws ec2 describe-regions --output text | cut -f 3)

### Iterating over AWS Regions and deleting Publickey ###
while read line
do
    echo "For region: $line"
    aws ec2 delete-key-pair --key-name $key_name --region $line
done <<< "$regions"
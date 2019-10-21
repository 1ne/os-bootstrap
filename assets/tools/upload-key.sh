#!/bin/bash

### Generate PublicKey (if required) ###
# ssh-keygen -t rsa -b 4096 -P '' -C `whoami` -f $HOME/.ssh/`whoami`
# mv $HOME/.ssh/`whoami` $HOME/.ssh/`whoami`.pem 

### Setting Keyname and Keypath ###
pub_key_path=$1
if [ -z "$1" ]; then
    pub_key_path="$HOME/.ssh/authorized_keys"
fi

key_name=$2
if [ -z "$2" ]; then
    key_name="$(cat $pub_key_path | cut -f3 -d' ')"
fi

### Enumerate AWS Regions ###
regions=$(aws ec2 describe-regions --output text | cut -f 3)

### Iterating over AWS Regions and uploading Publickey ###
while read line
do
    echo "For region: $line"
    aws ec2 import-key-pair --key-name $key_name --public-key-material file://$pub_key_path --region $line
done <<< "$regions"
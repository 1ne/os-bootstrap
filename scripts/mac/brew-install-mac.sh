#!/bin/bash

##### Make sure only non-root user is running the script #####
if [ "$(id -u)" == "0" ]; then
   echo "This script must NOT be run as root. Please run as normal user" 1>&2
   exit 1
fi

##### Configuring Basepath and Repo #####
base_path="https://raw.githubusercontent.com/1ne/os-bootstrap/master"

##### Configuring ZSH Reverse Search #####
sed -i -e "s/local border=0/local border=1/g" ~/.config/znt/n-list.conf

########## Installing Utilities #########

##### Configuring toprc and htoprc #####
mkdir -p ~/.config/htop/
curl -s $base_path/conf/generic/htoprc -o ~/.config/htop/htoprc
chmod 644 ~/.config/htop/htoprc

##### Installing libpcap first as its a dependency for other Utilities ####
brew install libpcap

##### Installing AWS Utilities ####
brew install python@2 python ruby
pip3 install --upgrade pip setuptools wheel
pip3 install --upgrade awscli aws-shell saws awslogs s3cmd
brew tap wallix/awless
brew install awless

##### Configuring AWS CLI Config #####
mkdir ~/.aws
curl -s $base_path/conf/generic/aws-config -o ~/.aws/config

##### All the Editor foo ####
brew install nano
brew install vim --with-override-system-vi
brew install neovim
pip3 install neovim
curl -sLf https://spacevim.org/install.sh | bash

##### Installing OS Utilities ####
brew install htop valgrind findutils ddate pv peco ccze
brew install openssh libssh2 sshrc openssl rsync screen unzip bzip2 xz ddar p7zip

##### Installing Network Utilities ####
brew install tcpdump tcpstat jnettop mtr tcptraceroute netcat nmap iperf3 whois arping fping liboping httpstat ipv6calc

##### Installing Homebrew Cask Upgrade ####
brew tap buo/cask-upgrade

##### Installing Monitoring Tools #####
pip3 install glances

##### Installing cURL with HTTP/2 Support ####
brew reinstall curl --with-c-ares  --with-libmetalink --with-libssh2 --with-nghttp2 --with-rtmpdump
#!/bin/bash

##### Make sure only non-root user is running the script #####
if [ "$(id -u)" == "0" ]; then
   echo "This script must NOT be run as root. Please run as normal user (ec2-user)" 1>&2
   exit 1
fi

##### Configuring Basepath and Repo #####
base_path="https://raw.githubusercontent.com/1ne/os-bootstrap/master"

##### Setting Hostname to Amazon #####
#read -p "Enter your Hostname (Press enter for ubuntu): " hostname
#hostname=${hostname:-ubuntu}
#sudo hostnamectl set-hostname --static $hostname
# use $a for last line append
#sudo sed -i -e '$i preserve_hostname: true' /etc/cloud/cloud.cfg

##### Updating the System #####
sudo apt update
sudo apt upgrade -y
sudo apt install build-essential jq curl ruby file mlocate binutils coreutils git irb python-setuptools ruby golang -y

##### Installing and enabling SSM Agent #####
curl -s https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb -o /tmp/amazon-ssm-agent.deb
sudo dpkg -i /tmp/amazon-ssm-agent.deb
sudo systemctl enable amazon-ssm-agent
sudo systemctl start  amazon-ssm-agent
sudo systemctl status amazon-ssm-agent

##### Installing atop #####
curl -s http://mirrors.kernel.org/ubuntu/pool/universe/a/atop/atop_2.3.0-1_amd64.deb -o /tmp/atop.deb
sudo dpkg -i /tmp/atop.deb
sudo service atop reload
sudo systemctl enable atop
sudo systemctl start  atop
sudo systemctl status atop

##### Prep for LinuxBrew #####
password=`openssl rand -base64 37 | cut -c1-20`
echo "$USER:$password" | sudo chpasswd

##### Installing LinuxBrew #####
echo  -e "\033[33;5mEnter the Password\033[0m: $password"
echo | sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"

##### Removing password for the user #####
sudo passwd -d `whoami`

##### Export LinuxBrew Path #####
echo 'export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"' >>~/.bash_profile
source ~/.bash_profile
chmod go-w '/home/linuxbrew/.linuxbrew/share'

##### Tapping Brew Extras and Installing libpcap first as its a dependency for other Utilities #####
brew tap linuxbrew/extra
brew install libpcap

##### Installing the Shells and Plugins #####
brew install bash fish zsh 
brew install zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-navigation-tools zsh-syntax-highlighting
brew install go

##### Adding Shells to list #####
echo '/home/linuxbrew/.linuxbrew/bin/bash' | sudo tee -a /etc/shells
echo '/home/linuxbrew/.linuxbrew/bin/zsh'  | sudo tee -a /etc/shells
echo '/home/linuxbrew/.linuxbrew/bin/fish' | sudo tee -a /etc/shells

##### Changing User Shells #####
sudo chsh -s /home/linuxbrew/.linuxbrew/bin/zsh $USER
#sudo chsh -s /usr/local/bin/bash $USER
#sudo chsh -s /usr/local/bin/fish $USER

##### Adding nanorc to config #####
curl -s https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh

##### Installing prezto #####
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
touch ~/.zshrc
/home/linuxbrew/.linuxbrew/bin/zsh -i -c 'setopt EXTENDED_GLOB && for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do ln -sf "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"; done'
curl -s $base_path/conf/linux/zshrc -o ~/.zshrc
curl -s $base_path/conf/generic/zpreztorc -o ~/.zpreztorc

##### Downloading Custom Utils #####
sudo curl -s $base_path/assets/tools/ls-instances -o /usr/bin/ls-instances
sudo chmod 777 /usr/bin/ls-instances
sudo curl -s $base_path/assets/tools/ls-instances-all -o /usr/bin/ls-instances-all
sudo chmod 777 /usr/bin/ls-instances-all
sudo curl -s $base_path/assets/tools/ciphers-test -o /usr/bin/ciphers-test
sudo chmod 777 /usr/bin/ciphers-test
sudo curl -s $base_path/assets/tools/clone-instance -o /usr/bin/clone-instance
sudo chmod 777 /usr/bin/clone-instance
curl -s $base_path/conf/generic/curl-format -o ~/curl-format

##### Setting Brew Path #####
sudo curl -s $base_path/conf/linux/brew-path -o /etc/sudoers.d/brew-path
sudo chmod 440 /etc/sudoers.d/brew-path

##### Giving user SuperPowers #####
cat << EOF
####################################################
Setting the Open file limits on the Box
####################################################
EOF
echo 'fs.file-max = 256000' | sudo tee -a /etc/sysctl.d/60-file-max.conf
echo '* soft nofile 256000' | sudo tee -a /etc/security/limits.d/60-nofile-limit.conf
echo '* hard nofile 256000' | sudo tee -a /etc/security/limits.d/60-nofile-limit.conf
echo 'root soft nofile 256000' | sudo tee -a /etc/security/limits.d/60-nofile-limit.conf
echo 'root hard nofile 256000' | sudo tee -a /etc/security/limits.d/60-nofile-limit.conf

##### Downloading the next Script #####
curl -s $base_path/scripts/ubuntu/ubuntu-sysdig-install.sh -o ~/sysdig-install.sh
chmod +x ~/sysdig-install.sh
curl -s $base_path/scripts/ubuntu/brew-install-ubuntu.sh -o ~/brew-install.sh
chmod +x ~/brew-install.sh

##### Print Additional ToDo Stuff #####
cat << EOF
####################################################
The instance will reboot and kick you out. Please login back and run the following commands
time ./sysdig-install.sh
screen -dmS brew bash brew-install.sh
####################################################
EOF

##### Rebooting Box #####
sudo reboot
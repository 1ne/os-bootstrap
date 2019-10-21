#!/bin/bash

##### Make sure only non-root user is running the script #####
if [ "$(id -u)" == "0" ]; then
   echo "This script must NOT be run as root. Please run as normal user (ec2-user)" 1>&2
   exit 1
fi

##### Configuring Basepath and Repo #####
base_path="https://raw.githubusercontent.com/1ne/os-bootstrap/master"

##### Defining the Confirm function #####
confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure you want set Hostname to $hostname? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

##### Setting Hostname to Amazon #####
read -p "Enter your Hostname (Press enter for amazon): " hostname
hostname=${hostname:-amazon}
sudo cp /etc/sysconfig/network /etc/sysconfig/network.orig
confirm && sudo sed -i "s/localhost\.localdomain/$hostname/" /etc/sysconfig/network

##### Updating the System #####
sudo yum update -y
sudo yum groupinstall -y 'Development Tools' && sudo yum install -y curl wget file git irb python-setuptools ruby mlocate awslogs fio iotop

##### Enabling AWSLogs #####
sudo chkconfig awslogs on
sudo service awslogs start
sudo service awslogs status

##### Installing SSM Agent #####
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo start amazon-ssm-agent
sudo status amazon-ssm-agent

##### Installing atop #####
sudo rpm -ivh https://www.atoptool.nl/download/atop-2.3.0-1.el6.x86_64.rpm
sudo chkconfig atop on
sudo service atop start
sudo service atop status

##### Installing Sysdig Monitoring Tools #####
sudo rpm --import https://s3.amazonaws.com/download.draios.com/DRAIOS-GPG-KEY.public
sudo curl -s -o /etc/yum.repos.d/draios.repo http://download.draios.com/stable/rpm/draios.repo
sudo rpm -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm

sudo yum -y install kernel-devel-$(uname -r)
sudo yum -y install sysdig
sudo yum update -y

##### Installing LinuxBrew #####
echo | sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"
echo 'export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"' >>~/.bash_profile
source ~/.bash_profile
chmod go-w '/home/linuxbrew/.linuxbrew/share'

##### Tapping Brew Extras and Installing libpcap first as its a dependency for other Utilities #####
brew tap linuxbrew/extra
brew install libpcap
brew install go

##### Installing the Shells and Plugins #####
brew install bash fish zsh 
brew install zsh-autosuggestions zsh-completions zshdb zsh-history-substring-search zsh-navigation-tools zsh-syntax-highlighting

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
echo 'fs.file-max = 256000' | sudo tee /etc/sysctl.d/60-file-max.conf
echo '* soft nofile 256000' | sudo tee /etc/security/limits.d/60-nofile-limit.conf
echo '* hard nofile 256000' | sudo tee -a /etc/security/limits.d/60-nofile-limit.conf
echo 'root soft nofile 256000' | sudo tee -a /etc/security/limits.d/60-nofile-limit.conf
echo 'root hard nofile 256000' | sudo tee -a /etc/security/limits.d/60-nofile-limit.conf

##### Downloading the next Script #####
curl -s $base_path/scripts/amzn/brew-install.sh -o ~/brew-install.sh
chmod +x ~/brew-install.sh

##### Print Additional ToDo Stuff #####
cat << EOF
####################################################
The instance will reboot and kick you out. Please login back and run the following command
screen -dmS brew bash brew-install.sh
####################################################
EOF

##### Rebooting Box #####
sudo reboot

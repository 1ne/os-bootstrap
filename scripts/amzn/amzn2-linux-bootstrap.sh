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
sudo hostnamectl set-hostname --static $hostname
# use $a for last line append
sudo sed -i -e '$i preserve_hostname: true' /etc/cloud/cloud.cfg

##### Updating the System #####
sudo yum update -y
sudo yum groupinstall -y 'Development Tools' && sudo yum install -y curl wget file git irb python-setuptools ruby mlocate util-linux-user fio iotop

##### Installing LinuxBrew #####
echo  -e "\033[33;5mEnter the Password\033[0m: $password"
echo | sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"

##### Export LinuxBrew Path #####
PATH="$(brew --prefix)/bin:$(brew --prefix)/sbin:$PATH"
test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile
chmod go-w '/home/linuxbrew/.linuxbrew/share'

##### Enabling SSM Agent #####
sudo systemctl enable amazon-ssm-agent
sudo systemctl start  amazon-ssm-agent
sudo systemctl status amazon-ssm-agent

##### Setting up CloudWatch SSM Parameter Store #####
instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
region=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}')
aws ssm put-parameter --name "AmazonCloudWatch-AmazonLinux" --description "AmazonCloudWatch Agent Config" --type "String" --value "$(curl -s $base_path/conf/linux/CWAgent.json)" --overwrite --region $region

##### Configuring AWS CloudWatch Agent #####
aws ssm send-command --document-name "AWS-ConfigureAWSPackage" --targets "Key=instanceids,Values=$instance_id" --parameters '{"action":["Install"],"version":["latest"],"name":["AmazonCloudWatchAgent"]}' --timeout-seconds 600 --max-concurrency "50" --max-errors "0" --region $region
sleep 15
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:AmazonCloudWatch-AmazonLinux -s

##### Installing atop and set sampling to 60 seconds #####
sudo rpm -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum --enablerepo=epel install atop -y
sudo sed -i 's/INTERVAL=600/INTERVAL=60/' /etc/sysconfig/atop
sudo systemctl enable atop
sudo systemctl start  atop
sudo systemctl status atop

##### Installing and enabling chrony for time sync #####
sudo yum erase 'ntp*' -y
sudo yum install chrony -y
sudo systemctl enable chronyd
sudo systemctl start chronyd
sudo systemctl status chronyd
chronyc sources -v
chronyc tracking

##### Installing Sysdig Monitoring Tools #####
sudo rpm --import https://s3.amazonaws.com/download.draios.com/DRAIOS-GPG-KEY.public
sudo curl -s -o /etc/yum.repos.d/draios.repo http://download.draios.com/stable/rpm/draios.repo
sudo yum -y install kernel-devel-$(uname -r)
sudo yum -y install sysdig
sudo yum -y install sysbench
sudo yum update -y

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
curl -s $base_path/conf/linux/zshrc -o ~/.zprezto/runcoms/zshrc
curl -s $base_path/conf/generic/zpreztorc -o ~/.zprezto/runcoms/zpreztorc

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
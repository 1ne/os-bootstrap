#!/bin/bash

##### Configuring Basepath and Repo #####
base_path="https://raw.githubusercontent.com/1ne/os-bootstrap/master"

##### Creating a non-privileged user #####
read -p "Enter your Username (Press enter for ec2-user): " user_name
user_name=${user_name:-ec2-user}
groupadd -g 1000 $user_name
useradd -u 1000 -g 1000 $user_name
usermod -a -G wheel $user_name
mkdir -p /home/$user_name
chown -R $user_name:$user_name /home/$user_name
chmod -R 700 /home/$user_name
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/sudo

##### Creating a non-privileged user #####
cp -r /root/.ssh/ /home/$user_name/
chown -R $user_name:$user_name /home/$user_name/
rm -rf /root/.ssh/
sudo passwd -d root
sudo passwd -d $user_name

##### Setting Hostname to Arch #####
read -p "Enter your Hostname (Press enter for arch): " hostname
hostname=${hostname:-arch}
sudo hostnamectl set-hostname --static $hostname

##### Updating the System and installing Yaourt #####
pacman -Syyu base-devel git
su - ec2-user
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
mv /etc/pacman.conf /etc/pacman.conf.bak
sudo curl -s $base_path/conf/linux/pacman.conf -o /etc/pacman.conf
chmod 644 /etc/pacman.conf

##### Downloading Arch Bootstrap #####
curl -s $base_path/scripts/arch/arch-linux-bootstrap.sh -o /home/$user_name/arch-linux-bootstrap.sh
chmod +x /home/$user_name/arch-linux-bootstrap.sh
chown $user_name:$user_name /home/$user_name/arch-linux-bootstrap.sh

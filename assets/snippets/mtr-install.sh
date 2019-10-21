#!/bin/bash

##### Installing required Tools and dependencies #####
sudo apt-get install build-essential ncurses-dev libncurses5-dev curl gettext bc autoconf git python ruby -y 
sudo yum groupinstall "Development Tools" -y
sudo yum install ncurses-devel curl -y

##### Compiling MTR from git HEAD and installing it #####
git clone https://github.com/traviscross/mtr.git
cd mtr
./bootstrap.sh
./configure --without-gtk
make
sudo make install
cd .. 
rm -rf mtr/

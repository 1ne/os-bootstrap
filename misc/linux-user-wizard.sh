#!/usr/bin/env bash
#set -x

# Checking if script is running as root
function checkroot {
    if ! [ $(id -u) = 0 ]
        then
            echo "Tou need to have root privileges to run this script
    Please try again, this time using 'sudo'. Exiting."
            exit
    fi
}
checkroot

# Mapping distro identification commands
YUM_CMD=$(which yum)
APT_GET_CMD=$(which apt-get)


# Capture Ctrl + C 
trap ctrl_c INT
function ctrl_c() {
        echo ""
        echo "GOOD BYE -- LinuxUserWizard"
        echo ""
        exit
}

# Initialize logs at the script launch, if log file is not there
function initializelogs {
    if [ ! -f /var/log/luw.log ]
        then
            touch /var/log/luw.log
            echo "################################" >> /var/log/luw.log
            echo `date` -- "Log file initiated"  >> /var/log/luw.log
            echo "################################" >> /var/log/luw.log
    fi
}

initializelogs # initializing the log file at launch

function logentry {
    echo `date` "|" "Operation: "$logoperation "|" "User: "$luwuser >> /var/log/luw.log
}

function exiting {
    echo "Do you want to do another operation? (Y/N)"
    read exitanswer
    if [ "$exitanswer" = "y" ] || [ "$exitanswer" = "Y" ]
        then
            mainmenu
    elif [ "$exitanswer" = "n" ] || [ "$exitanswer" = "N" ]
        then
            echo ""
            echo "GOOD BYE -- LinuxUserWizard"
            echo ""
            logoperation="Exited the program" && logentry
            exit
    else
        echo "Wrong option, please enter 'Y' or 'N'"
    exiting
    fi
}

function wrongoption {
    echo "Wrong option, please enter 'Y' or 'N'"
    exiting

}

function sshdirmake {
    mkdir /home/$luwuser/.ssh
    logoperation="SSH directory created"
    logentry
    touch /home/$luwuser/.ssh/authorized_keys
    logoperation="authorized_keys file created"
    logentry
}

function keypairgen {
    ssh-keygen -t rsa -f /home/$luwuser/.ssh/id_rsa -q -N ""
    cat /home/$luwuser/.ssh/id_rsa.pub >> /home/$luwuser/.ssh/authorized_keys
    chmod 600 /home/$luwuser/.ssh/authorized_keys
    chown -R $luwuser /home/$luwuser
    logoperation="SSH key generated"
    logentry

}

function packageinstaller {
    echo $YUM_CMD > /dev/null
    echo $APT_GET_CMD > /dev/null
    if [[ ! -z $YUM_CMD ]]
        then
            echo "Using 'yum' to install the requirements.." && sleep 2
            yum -y install $packagetoinstall
    elif [[ ! -z $APT_GET_CMD ]]
        then
            echo "Using 'apt-get' to install the requirements.." && sleep 2
            apt-get install $packagetoinstall -y

    else
        echo "Can't find package manager" && sleep 2
        exiting
    fi
}

function sudoprivilage {
    if grep -Fxq "$luwuser" /etc/sudoers
        then
        echo "User is already in /etc/sudoers"
    else
        echo "Would you like to give SUDO privilages (administrative access) to this user? (y\n)"
        read sudoanswer
        if [ $sudoanswer = "y" ] || [ $sudoanswer = "Y" ]
            then
                echo "$luwuser    ALL=(ALL:ALL) ALL" >> /etc/sudoers
            else
                echo "User will be left with no sudo access"
        fi
    fi
}


function mainmenu {

clear
echo       "#########################################################"
echo       "#              ***** LINUX USER WIZARD *****            #"
echo       "#########################################################"
echo       "#                                                       #"
echo       "# - Create a user with SSH key              - Press 1   #"
echo       "# - Remove a user and keys                  - Press 2   #"
echo       "# - Enable password login with no key       - Press 3   #"
echo       "# - Disable password login with no key      - Press 4   #"
echo       "# - View users with a shell                 - Press 5   #"
echo       "# - View user's private key                 - Press 6   #"
echo       "# - View logs                               - Press 7   #"
echo       "# - Delete/Re-initialize logs               - Press 8   #"
echo       "# - Exit                                    - Press 9   #"
echo       "#                                                       #"
echo       "#########################################################"
echo       "#                ***** AWS TOOLBOX  *****               #"
echo       "#########################################################"
echo       "#                                                       #"
echo       "# - Install latest AWS CLI                  - Press 10  #"
echo       "# - Install/Configure systat SAR            - Press 11  #"
echo       "# - Install/Configure CloudWatch Logs Agent - Press 12  #"
echo       "# - Generate SOS report for AWS Support     - Press 13  #"
echo       "# - Install/Configure Java                  - Press 14  #"
echo       "# - Install/Compile iPerf v2.0.5            - Press 15  #"
echo       "#                                                       #"
echo       "#########################################################"
echo       "                                                        "
echo       " - L.U.W. logs:/var/log/luw.log                         "
echo       "                                                        "
echo       "   Select a number and hit 'Enter'                      "

read answer





if [ "$answer" = "1" ] ### OPTION 1 START
    then
        echo "Please enter a username"
        read luwuser
        if [ -d /home/$luwuser ]
            then echo "Homefolder exists do you want to overwrite it? (y/n)"
            read homefolderanswer
            if [ "$homefolderanswer" = "y" ] || [ "$homefolderanswer" = "Y" ]
                then
                    rm -rf /home/$luwuser && logoperation="Homefolder deleted" && logentry
                    useradd $luwuser -s /bin/bash
                    chown -R $luwuser /home/$luwuser
                    sshdirmake
                    keypairgen
                    sudoprivilage
                    exiting
            else
                echo "Not creating the user since you want to keep the homefolder"
                echo "Leaving homefolder intact"
                echo "Do you still want to create SSH key and put in user's home folder? (y/n)"
                read keyans
                if [ "$keyans" = "y" ] || [ "$keyans" = "Y" ]
                    then
                    if [ ! -d /home/$luwuser/.ssh]; then
                        sshdirmake
                    fi
                    keypairgen
                fi
            sudoprivilage    
            exiting
            fi
        fi


    if [ ! -d /home/$luwuser ]
        then
            useradd $luwuser -s /bin/bash && logoperation="New user added" && logentry
            if [ ! -d /home/$luwuser ] # check due ubuntu does not create home folder on user creation
                then
                    mkdir /home/$luwuser && logoperation="Homefolder created" && logentry
            fi
            sshdirmake
            keypairgen
            sudoprivilage
            exiting
    fi
fi ### OPTION 1 END


if [ "$answer" = "2" ] ### OPTION 2 START
    then
        echo "Please enter a username to delete"
        read luwuser
        if [ -d /home/$luwuser ]
            then
                userdel -r $luwuser
                sed -i '/$luwuser/d' /etc/passwd
                sed -i'/$luwuser/d' /etc/sudoers
                rm -rf /home/$luwuser
                if [ ! -d /home/$luwuser ]; then
                    echo "User homefolder deleted"
                    logoperation="User deleted" && logentry
                fi
		if [ -f /var/spool/mail/$luwuser ]; then
		    rm -rf /var/spool/mail/$luwuser
		    echo "Mail file removed"
		fi
                exiting
        else
            sed -i '/$luwuser/d' /etc/passwd
            sed -i '/$luwuser/d' /etc/sudoers
            if [ -f /var/spool/mail/$luwuser ]; then
		rm -rf /var/spool/mail/$luwuser
                echo "Mail file removed"
	    fi
            echo "Home folder does not exist"
            logoperation="Homefolder could not be found" && logentry
            exiting
        fi
fi ### OPTION 2 END


if [ "$answer" = "3" ] ### OPTION 3 START
    then
        if [ -f /etc/ssh/sshd_config ]
            then
                sed -i 's/#PasswordAuthentication/PasswordAuthentication/' /etc/ssh/sshd_config && logoperation="SSH via password enabled" && logentry
                echo "SSH with password is enabled"
                service sshd restart
                service ssh restart
                exiting
        else
            echo "sshd_config file is not under /etc/ssh, please edit manually and set
#PasswordAuthentication yes to PasswordAuthentication yes | remove # (uncomment)" && logoperation="sshd_config can't be found" && logentry
            exiting
        fi
fi ### OPTION 3 END


if [ "$answer" = "4" ] ### OPTION 4 START
    then
        if [ -f /etc/ssh/sshd_config ]
            then
                sed -i 's/PasswordAuthentication/#PasswordAuthentication/' /etc/ssh/sshd_config && logoperation="SSH via password disabled" && logentry
                echo "SSH with password is disabled"
                service sshd restart
                service ssh restart
                exiting
        else
            echo "sshd_config file is not under /etc/ssh, please edit manually and set
#PasswordAuthentication yes to PasswordAuthentication yes | remove # (uncomment)" && logoperation="sshd_config can't be found" && logentry
            exiting
        fi
fi ### OPTION 4 END


if [ "$answer" = "5" ]
    then
        cat /etc/passwd | grep /bin/bash | less && logoperation="Viewed users with shell" && logentry
        mainmenu
fi


if [ "$answer" = "6" ]
    then
        echo "Please enter the username to view it's private key"
        read keyviewuser
    if [ -f /home/$keyviewuser/.ssh/id_rsa ]
        then
            cat /home/$keyviewuser/.ssh/id_rsa | less && logoperation="Private Key viewed" && logentry
            exiting
    else
        echo "Private key is not under" /home/$keyviewuser "or not named id_rsa" && logoperation="Private key can't be found" && logentry
        exiting
    fi
fi

if [ "$answer" = "7" ]
    then
        logoperation="Viewed logs" && logentry && less /var/log/luw.log
        mainmenu
fi

if [ "$answer" = "8" ]
    then
        rm -f /var/log/luw.log
        initializelogs
        echo "Logs has been deleted and re-initialized"
        exiting
fi

if [ "$answer" = "9" ]
    then
        echo ""
        echo "GOOD BYE -- LinuxUserWizard"
        echo ""
        exit
fi

if [ "$answer" = "10" ]
    then
    packagetoinstall="unzip" && packageinstaller
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "/tmp/awscli-bundle.zip"
    unzip /tmp/awscli-bundle.zip
    ./tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
    echo "Would you like to configure AWS CLI now? (y/n)"
        read awsclians
    if [ "$awsclians" = "y" ] || [ "$awsclians" = "Y" ]
        then
            aws configure && logoperation="AWS CLI Installed" && logentry && exiting
        else
            echo "Please issue 'aws configure' command after closing this tool"
            logoperation="AWS CLI Installed" && logentry
        exiting
    fi
    rm -f /tmp/awscli-bundle.zip
    exiting
fi

if [ "$answer" = "11" ]
    then
        #packagetoinstall="sysstat" && packageinstaller
        sed -i 's/ENABLED="false"/ENABLED="true"/' /etc/default/sysstat
        sed -i 's/5-55\/10/*\/2/' /etc/cron.d/sysstat
        service sysstat restart
        echo "SYSSTAT installed & configured"
        echo "SAR logs are under /var/log/sa and will be kept in rotation for 30 days" && sleep 2
        exiting
fi

if [ "$answer" = "12" ]
    then
        echo "Coming soon."
        exiting
fi

if [ "$answer" = "13" ]
    then
        wget -q -O ginfo.sh 'http://bit.ly/1scykJV'
        chmod 755 ginfo.sh
        ./ginfo.sh
        exiting
fi

if [ "$answer" = "14" ]
    then
        echo "Coming soon."
        exiting
fi

if [ "$answer" = "15" ]
    then
        packagetoinstall="gcc-c++" && packageinstaller
        wget http://sourceforge.net/projects/iperf/files/iperf-2.0.5.tar.gz/download
        mv download iperf-2.0.5.tar.gz
        tar -xzvf iperf-2.0.5.tar.gz
        cd iperf-2.0.5
        ./configure
        make
        make install
fi

if [ "$answer" != "1" ] && [ "$answer" != "2" ] && [ "$answer" != "3" ] && [ "$answer" != "4" ] && [ "$answer" != "5" ] && [ "$answer" != "6" ] \
&& [ "$answer" != "7" ] && [ "$answer" != "8" ] && [ "$answer" != "9" ] && [ "$answer" != "10" ] && [ "$answer" != "11" ] && [ "$answer" != "12" ] \
 && [ "$answer" != "13" ] && [ "$answer" != "14" ] && [ "$answer" != "15" ]
    then
        mainmenu
fi

}

mainmenu





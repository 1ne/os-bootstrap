# os-bootstrap
### For Amazon Linux 2

```bash
curl -s https://raw.githubusercontent.com/1ne/os-bootstrap/master/scripts/amzn/amzn2-linux-bootstrap.sh -o amzn2-linux-bootstrap.sh
screen -dmS bootstrap bash amzn2-linux-bootstrap.sh
screen -r #to reconnect to the session
```
Use CTRL + a,d to disconnect from session after giving the password in the script.  
After reboot please login back and run the following command
```bash
screen -dmS brew bash brew-install.sh
```

### For Amazon Linux 1

```bash
curl -s https://raw.githubusercontent.com/1ne/os-bootstrap/master/scripts/amzn/amzn1-linux-bootstrap.sh -o amzn1-linux-bootstrap.sh
screen -dmS bootstrap bash amzn1-linux-bootstrap.sh
```
After reboot please login back and run the following command
```bash
screen -dmS brew bash brew-install.sh
```

### For macOS

```bash
curl -s https://raw.githubusercontent.com/1ne/os-bootstrap/master/scripts/mac/bootstrap-mac.sh -o bootstrap-mac.sh
chmod +x bootstrap-mac.sh
time ./bootstrap-mac.sh
```
After opening iTerm2
```bash
screen -dmS brew bash brew-install.sh
```

### For RHEL7

```bash
curl -s https://raw.githubusercontent.com/1ne/os-bootstrap/master/scripts/rhel7/rhel7-linux-bootstrap.sh -o rhel7-linux-bootstrap.sh
chmod +x rhel7-linux-bootstrap.sh
time ./rhel7-linux-bootstrap.sh
```
After reboot please login back and run the following command
```bash
time ./sysdig-install.sh
screen -dmS brew bash brew-install.sh
```

### For Ubuntu

```bash
curl -s https://raw.githubusercontent.com/1ne/os-bootstrap/master/scripts/ubuntu/ubuntu-linux-bootstrap.sh -o ubuntu-linux-bootstrap.sh
chmod +x ubuntu-linux-bootstrap.sh
time ./ubuntu-linux-bootstrap.sh
```
After reboot please login back and run the following command
```bash
time ./sysdig-install.sh
screen -dmS brew bash brew-install.sh
```
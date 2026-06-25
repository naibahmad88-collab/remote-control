#!/bin/bash

# Install the needed applications
# If applications installed, don't install again
# dpkg is a tool to install, build, remove and manage Debian packages.
# The -s flag show the status of an installed package. 
# If the package is not installed, the result will return as negative and an installation will be initiated.

   dpkg -s geoip-bin &> /dev/null  

    if [ $? -ne 0 ]

        then
            sudo apt-get -qq upgrade
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq git htop < /dev/null > /dev/null geoip-bin
            echo  "[#] geoip-bin is already installed"  
            
        else
            echo  "[#] geoip-bin is already installed"
    fi
 
   dpkg -s tor &> /dev/null  

    if [ $? -ne 0 ]

        then 
            sudo apt-get -qq upgrade
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq git htop < /dev/null > /dev/null tor
            echo "[#] tor is already installed"

        else
            echo  "[#] tor is already installed"
    fi  

   dpkg -s sshpass &> /dev/null  

    if [ $? -ne 0 ]

        then
            sudo apt-get -qq upgrade
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq git htop < /dev/null > /dev/null sshpass
            echo "[#] sshpass is already installed"

        else
            echo  "[#] sshpass is already installed"
    fi 
# As nipe has its own directory when installed, 
# use the if script to find out if a nipe directory is created.
# If not an installation will be initiated.
   
if [ -d nipe ] 
then
    echo "[#] nipe is already installed." 
else
    git clone --quiet https://github.com/htrgouvea/nipe && cd nipe
    sudo cpan install Try::Tiny Config::Simple JSON &> /dev/null 
    sudo perl nipe.pl install &> /dev/null 
    echo "[#] nipe is already installed."
fi

# Check network connection is anonymous, if not alert user & exit
# Nipe is an engine that aims on making the Tor network the default gateway
# In order to run Nipe, first it needs to start and then check for the status.
# As Nipe needs time to connect, a sleep command is added.

cd nipe
 
 sudo perl nipe.pl restart
 sleep 5
 status=$(sudo perl nipe.pl status | grep true | awk '{print $3}')
 
# Once an anonymous IP is received, the status will show as 'true'.
# If not, a warning text will appear instead.
 
 if [[ $status == 'true' ]]
 then
      echo  '[#] You are anonymous.. Connecting to remote server.'
      
 else
      echo '[*] You are NOT anonymous.. Exit.' 
      
      
 fi

# curl ifconfig.io is to retrieve public ip address
# geoiplookup is to find the country that an IP address or hostname originates from.

ipinfo=$(curl -s ifconfig.io)
country=$(geoiplookup $ipinfo | awk '{print $4,$5}')
echo "[*] Your Spoofed IP address is: $ipinfo , Spoofed Country: $country "

# Allow user to specify Domain/IP Address, save into variable.
# function script is used for executing multiple tasks with a single entry.

function targetinfo()
{
	echo '[?] Specify a Domain/User@IP address to scan: ' 
	read target
}
targetinfo	
echo '[*] Connecting To Remote Server'
# To hide password in SSHPASS
export SSHPASS=tc 
# To input remote server info                    
remoteip=tc@192.168.11.130           

uptime=$(sshpass -e ssh $remoteip "uptime")
echo Uptime:$uptime
ipaddress=$(sshpass -e ssh $remoteip "hostname -I")
echo IP address:$ipaddress
sshpass -e ssh $remoteip "whois $remoteip | grep -i country"

# To create a file for the logs.
touch NR.log        

echo "[*] Whoising victim's address: "
sshpass -e ssh $remoteip "whois $target > whois_$target"
# pwd command is entered to get the current directory location of the remote server.
fileloc=$(sshpass -e ssh $remoteip "pwd")
# scp is used to transfer the saved files from remote server to local machine.
sshpass -e scp $remoteip:$fileloc/whois_$target /home/kali/nipe 
echo "[@] Who is data was saved into /home/kali/nipe/whois_$target"
# To put a timestamp on the event.
date >> NR.log
# To append the data into the log file.
echo "Whois data collected for: $target" >> NR.log  

echo "[*] Scanning victim's address: "
sshpass -e ssh $remoteip "nmap -Pn $target -sV > nmap_$target"
# pwd command is entered to get the current directory location of the remote server.
fileloc=$(sshpass -e ssh $remoteip "pwd")
# scp is used to transfer the saved files from remote server to local machine.
sshpass -e scp $remoteip:$fileloc/nmap_$target /home/kali/nipe
echo "[@] Nmap scan was saved into /home/kali/nipe/nmap_$target"
# To put a timestamp on the event.
date >> NR.log 
# To append the data into the log file.           
echo "Nmap data collected for: $target" >> NR.log







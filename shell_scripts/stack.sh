#!/bin/bash

######
## Purpose : Install web server , application and DB 
######

### Variables
LOG_FILE=/tmp/stack.log
rm -f /tmp/stack.log
TOMCAT_CONN_URL="http://www-us.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.42-src.tar.gz"
CONN_TAR_FILE=$(echo $TOMCAT_CONN_URL | awk -F / '{print $NF}')
CONN_TAR_DIR=$(echo $CONN_TAR_FILE | sed -e 's/.tar.gz//')


### Check and run the script as root user
ID=$(id -u)
if [ $ID -ne 0 ]; then
	echo "You should be a root user to perform this script"
	exit 1
fi

### Functions
Succ() {
	echo -e "\e[32m✓ $1\e[0m"
}

Err() {
	echo -e "\e[31m✗ $1\e[0m"
}

##### Install Apache HTTPD
yum install httpd httpd-devel -y &>$LOG_FILE
if [ $? -eq 0 ]; then 
	Succ "Installation of Apache HTTPD is completed"
else
	Err "Installation of Apache HTTPD is failed"
	exit 1
fi

##### Start Web Server
systemctl enable httpd &>$LOG_FILE
systemctl start httpd &>$LOG_FILE
if [ $? -eq 0 ]; then 
	Succ "Started Apache Web Server"
else
	Err "Failed to Start Apache Web Server "
	exit 1
fi

##### Configure mod-jk 
wget $TOMCAT_CONN_URL -O /opt/$CONN_TAR_FILE &>$LOG_FILE
if [ $? -eq 0 ]; then
	Succ "Downloading MOD-JK ... Successful"
else
	Err "Downloading MOD-JK ... Failure"
	exit 1
fi


##### Install TOmcat


##### Install MariaDB
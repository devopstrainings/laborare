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

TOMCAT_URL=http://www-us.apache.org/dist/tomcat/tomcat-9/v9.0.1/bin/apache-tomcat-9.0.1.tar.gz
TOMCAT_TAR_FILE=$(echo $TOMCAT_URL | awk -F / '{print $NF}')
TOMCAT_DIR=$(echo $TOMCAT_TAR_FILE | sed -e 's/.tar.gz//')

TOMCAT_IP_ADDR=localhost
MYSQL_IP_ADDR=localhost

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
echo -e "\e[35m ######  WEB SERVER  ######\e[0m"
yum install httpd httpd-devel gcc -y &>$LOG_FILE
if [ $? -eq 0 ]; then 
	Succ "Installation of Apache HTTPD is completed"
else
	Err "Installation of Apache HTTPD is failed"
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

## Extract Tomcat 
cd /opt
tar xf $CONN_TAR_FILE
cd $CONN_TAR_DIR/native
./configure --with-apxs=/usr/bin/apxs &>$LOG_FILE && make clean &>$LOG_FILE && make &>$LOG_FILE && make install &>$LOG_FILE
if [ $? -eq 0 ]; then 
	Succ "Installing MOD-JK ... Successful"
else
	Err "Installing MOD-JK ... Failure"
	exit 1
fi

echo 'LoadModule jk_module modules/mod_jk.so
JkWorkersFile conf.d/workers.properties
JkLogFile logs/mod_jk.log
JkLogLevel info
JkLogStampFormat "[%a %b %d %H:%M:%S %Y]"
JkOptions +ForwardKeySize +ForwardURICompat -ForwardDirectories
JkRequestLogFormat "%w %V %T"
JkMount /student tomcatA
JkMount /student/* tomcatA' >/etc/httpd/conf.d/mod_jk.conf

echo '### Define workers
worker.list=tomcatA
### Set properties
worker.tomcatA.type=ajp13
worker.tomcatA.host=TOMCAT_IP_ADDR
worker.tomcatA.port=8009' >/etc/httpd/conf.d/workers.properties

sed -i -e "s/TOMCAT_IP_ADDR/$TOMCAT_IP_ADDR/" /etc/httpd/conf.d/workers.properties

##### Start Web Server
systemctl enable httpd &>$LOG_FILE
systemctl restart httpd &>$LOG_FILE
if [ $? -eq 0 ]; then 
	Succ "Started Apache Web Server"
else
	Err "Failed to Start Apache Web Server "
	exit 1
fi



##### Install TOmcat
echo -e "\e[35m ######  APP SERVER  ######\e[0m"
yum install java -y &>$LOG_FILE
java -version &>$LOG_FILE
if [ $? -eq 0 ]; then 
	Succ "Installing Java ... Successful"
else
	Err "Installing Java ... Failure"
	exit 1
fi

cd /opt
wget $TOMCAT_URL -O $TOMCAT_TAR_FILE &>$LOG_FILE
if [ $? -eq 0 ]; then 
	Succ "Downloading Tomcat ... Successful"
else
	Err "Downloading TOmcat ... Failure"
	exit 1
fi

tar xf $TOMCAT_TAR_FILE
cd $TOMCAT_DIR
rm -rf webapps/*
wget https://github.com/carreerit/cogito/raw/master/appstack/student.war -O webapps/student.war &>$LOG_FILE
STAT1=$?
wget https://github.com/carreerit/cogito/raw/master/appstack/mysql-connector-java-5.1.40.jar -O lib/mysql-connector-java-5.1.40.jar &>$LOG_FILE
STAT2=$?

# if [ $STAT1 -eq 0 ] && [ $STAT2-eq 0  ]; then    ### you can use this also for logical AND
if [ $STAT1 -eq 0 -a $STAT2 -eq 0  ]; then 
	Succ "Configuring Application Server ... Successful"
else
	Err "Configuring Application Server ... Failure"
	exit 1
fi

sed -i -e '$ i <Resource name="jdbc/TestDB" auth="Container" type="javax.sql.DataSource" maxTotal="100" maxIdle="30" maxWaitMillis="10000" username="student" password="student@1" driverClassName="com.mysql.jdbc.Driver" url="jdbc:mysql://MYSQL_IP_ADDR:3306/studentapp"/>' conf/context.xml

sed -i -e "s/MYSQL_IP_ADDR/$MYSQL_IP_ADDR/" conf/context.xml

pkill java &>$LOG_FILE
sh bin/startup.sh &>$LOG_FILE
if [ $? -eq 0 ]; then 
	Succ "Starting Tomcat ... Successful"
else
	Err "Starting Tomcat ... Failure"
	exit 1
fi


##### Install MariaDB
echo -e "\e[35m ######  DB SERVER  ######\e[0m"
yum install mariadb mariadb-server -y &>$LOG_FILE
if [ $? -eq 0 ]; then 
	Succ "Installing MariaDB ... Successful"
else
	Err "Installing MariaDB ... Failure"
	exit 1
fi

systemctl enable mariadb &>$LOG_FILE
systemctl start mariadb &>$LOG_FILE
if [ $? -eq 0 ]; then 
	Succ "Starting MariaDB ... Successful"
else
	Err "Starting MariaDB ... Failure"
	exit 1
fi

echo "create database IF NOT EXISTS studentapp;
use studentapp;
CREATE TABLE IF NOT EXISTS Students(student_id INT NOT NULL AUTO_INCREMENT,
	student_name VARCHAR(100) NOT NULL,
    student_addr VARCHAR(100) NOT NULL,
	student_age VARCHAR(3) NOT NULL,
	student_qual VARCHAR(20) NOT NULL,
	student_percent VARCHAR(10) NOT NULL,
	student_year_passed VARCHAR(10) NOT NULL,
	PRIMARY KEY (student_id)
);
grant all privileges on studentapp.* to 'student'@'localhost' identified by 'student@1';" >/tmp/student.sql

mysql </tmp/student.sql  &>$LOG_FILE
if [ $? -eq 0 ]; then 
	Succ "Configuring MariaDB ... Successful"
else
	Err "Configuring MariaDB ... Failure"
	exit 1
fi





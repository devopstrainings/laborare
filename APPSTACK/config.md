# Assuming the following .

#### `Tomcat Server IP Address : 10.128.0.5`
#### `DB Server IP Address : 10.128.0.6`
#### `OS on both machines is CentOS 7`


# I) Tomcat Server Setup

### 1) Install Tomcat from Binary Disribution, Download required war and jar files
```
# cd /root
# wget http://redrockdigimark.com/apachemirror/tomcat/tomcat-9/v9.0.1/bin/apache-tomcat-9.0.1.tar.gz
# tar -xf apache-tomcat-9.0.0.M26.tar.gz
# mv apache-tomcat-9.0.0.M26 tomcat
# cd tomcat
# cd webapps
# rm -rf *
# wget https://github.com/carreerit/cogito/raw/master/appstack/student.war
# cd ../lib
# wget https://github.com/carreerit/cogito/raw/master/appstack/mysql-connector-java-5.1.40.jar
# cd ../bin
# sh startup.sh
```

### 2) Configure your tomcat to connect to DB.
```
# vim /root/tomcat/conf/context.xml
     ### Add the following content to your file just before last line.
<Resource name="jdbc/TestDB" auth="Container" type="javax.sql.DataSource"
               maxTotal="100" maxIdle="30" maxWaitMillis="10000"
               username="student" password="student@1" driverClassName="com.mysql.jdbc.Driver"
               url="jdbc:mysql://10.128.0.6:3306/studentapp"/>

### Once changes are done then restart the tomcat
# /root/tomcat/bin/shutdown.sh  (or)  # pkill java
# /root/tomcat/bin/startup.sh
```


# II) MariaDB Server Setup

### 1) Install and Start DB Services.
```
# yum install mariadb mariadb-server -y
# systemctl enable mariadb
# systemctl start mariadb
```

### 2) Create studentapp DB and required tables , Set username and password to connect to DB
```
# vim studentapp.sql     <Create this file>
create database studentapp;
use studentapp;
CREATE TABLE Students(student_id INT NOT NULL AUTO_INCREMENT,
	student_name VARCHAR(100) NOT NULL,
    student_addr VARCHAR(100) NOT NULL,
	student_age VARCHAR(3) NOT NULL,
	student_qual VARCHAR(20) NOT NULL,
	student_percent VARCHAR(10) NOT NULL,
	student_year_passed VARCHAR(10) NOT NULL,
	PRIMARY KEY (student_id)
);
grant all privileges on studentapp.* to 'student'@'10.128.0.5' identified by 'student@1';

### Run the following command to create DB
# mysql <studentapp.sql
```

# III) Verify DB Connection from Tomcat server.

```
# mysql -h 10.128.0.6 -u student -pstudent@1
```
### If the above command provides MariaDB prompt then connection is successful.
### Verify the DB using following commands.
```
> show databases;
> use studentapp;
> show tables;
> select * from Student;
```

# IV) Install & Configure Web Server to connect to Application

### 1) Install web Server.
```
# yum install httpd httpd-devel -y
# systemctl enable httpd
# systemctl start httpd
```

### 2) Download and configure mod_jk with web server
####  Here is the reference URL https://jeljo.wordpress.com/2013/11/23/apache-2-4-7-tomcat-7-integration/

```
# cd /root
# wget http://redrockdigimark.com/apachemirror/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.42-src.tar.gz
# tar xf tomcat-connectors-1.2.42-src.tar.gz
# cd tomcat-connectors-1.2.42-src/native
# yum install gcc -y
# ./configure --with-apxs=/usr/bin/apxs
# make
# make install
# cd /etc/httpd/conf.d
# vim modjk.conf
LoadModule jk_module modules/mod_jk.so
JkWorkersFile conf.d/workers.properties
JkLogFile logs/mod_jk.log
JkLogLevel info
JkLogStampFormat "[%a %b %d %H:%M:%S %Y]"
JkOptions +ForwardKeySize +ForwardURICompat -ForwardDirectories
JkRequestLogFormat "%w %V %T"
JkMount /student tomcatA
JkMount /student/* tomcatA

# vim workers.properties

### Define workers
worker.list=tomcatA
### Set properties
worker.tomcatA.type=ajp13
worker.tomcatA.host=10.128.0.5
worker.tomcatA.port=8009

# systemctl restart httpd

```


--------------------
-- Modified by Raghu

#!/bin/bash

ID=$(id -u)

case $ID in
	0)
	case $1 in
		WEB) 
			echo "Installing web server"
			yum install httpd -y
			;;
		APP) 
			echo "Installing app server"
			;;
		DB) 
			echo "Installing mariadb server"
			;;
		*) 
			echo "Invalid option"
			echo "$0 WEB|APP|DB"
			exit 1
			;;
	esac
	;;
	
	*) 
		echo "You should be a root user to execute this script"
		exit 2
	;;
esac
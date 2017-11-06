#!/bin/bash

SUCCESS() {
	echo -e "\e[32m $1 \e[0m"
}

FAILURE() {
	echo -e "\e[31m $1 \e[0m"
}


SUCCESS "Installation of HTTPD is success"
FAILURE "Installation of HTTPD is failure"
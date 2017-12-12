#!/bin/bash

echo -e "\n\e[31m Installing Docker\e[0m"
curl -s https://raw.githubusercontent.com/linuxautomations/docker/master/install-ce.sh | bash

echo -e "\nInstalling UCP\n"

#yum install bind-utils -y &>/dev/null

read -p 'Enter UCP Server Public IP Address: ' IP
docker image pull docker/ucp:2.2.4
docker container run --rm -it --name ucp \
  -v /var/run/docker.sock:/var/run/docker.sock \
  docker/ucp:2.2.4 install \
  --host-address $IP \
  --admin-username admin \
  --admin-password password 

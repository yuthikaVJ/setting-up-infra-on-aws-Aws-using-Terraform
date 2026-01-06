#!/bin/bash

##############################
# Docker Installation Script #                                                           
# Author: Realsteel          #                                                           
# Date: 2026-01-05           #                                                               
# Version: 1.0               #
#############################

set -e 


#System Update
 apt update  -y

#Docker Installation
 apt install docker.io -y

#Start and Enable Docker Service
systemctl start docker
systemctl enable docker

#Add ubuntu to docker group
 usermod -aG docker ubuntu

#pull the docker image
docker pull   <ddd>

#Run the docker container
docker run  --name web_app -d -p 80:80   <ddd>


#End of script
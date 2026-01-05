!#/bin/bash

##############################
# Docker Installation Script #                                                           
# Author: Realsteel          #                                                           
# Date: 2024-06-15           #                                                               
# Version: 1.0               #
#############################


#System Update
sudo apt update

#Docker Installation
sudo apt install docker.io -y

#Add ubuntu to docker group
sudo usermod -aG docker ubuntu

#pull the docker image
docker pull 

#Run the docker container
docker run -d -p 80:80 yuthikarathod/myapp:latest

#End of script
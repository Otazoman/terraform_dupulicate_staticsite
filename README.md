# terraform_dupulicate_staticsite  
AWS and Azure and GoogleCloud and Terraform Develop Environment  
  
# Description  
It is a Docker container that combines AWS, Azure, GoogleCloud,   
and Terraform development environments into one.  

# Operating environment  
Ubuntu 24.04.1 LTS  
Docker version 27.2.0  

# Usage  
$ docker build . -t multicloud-ubuntu \
--build-arg nvm_ver=0.39.7 \
--build-arg ruby_ver=3.3.5 \
--build-arg python_ver=3.12.6  
$ mkdir terraform  
$ docker container run --name terraform-dev -h terraform-dev -it -d \  
 --mount type=bind,src=$(pwd)/terraform,dst=/root/terraform \  
 --restart=always \  
 -e TZ=Asia/Tokyo multicloud-ubuntu /bin/bash  
$ docker exec -it terraform-dev /bin/bash  

### Caution  
If you need to run the docker command with sudo, prefix it with sudo.

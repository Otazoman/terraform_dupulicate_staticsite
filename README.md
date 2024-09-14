# terraform_dupulicate_staticsite  
AWS and Azure and GoogleCloud and Terraform Develop Environment  
  
# Description  
It is a Docker container that combines AWS, Azure, GoogleCloud,   
and Terraform development environments into one.  

# Operating environment  
Ubuntu 24.04.1 LTS  
Docker version 27.2.0  

# Usage  
```
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
```

### Caution  
If you need to run the docker command with sudo, prefix it with sudo.  

# Setting Environment(Run in a Docke container)  
1.Get AWS authentication information  
Create a user for the CLI in the AWS Management Console and obtain a secret.  

2.Get GoogleCloud serviceaccount information
```
# gcloud init
Pick cloud project to use:
[1] sample-project
Please enter numeric choice or text value (must exactly match list
item):1

Do you want to configure a default Compute Region and Zone? (Y/n)? Y
[34] asia-northeast1-a
Please enter numeric choice or text value (must exactly match list
item):  34

# export GCP_PROJECT_ID=$(gcloud config get-value project)
# env | grep GCP_PROJECT_ID

# gcloud iam service-accounts create terraform-serviceaccount --display-name "Account for Terraform"
# gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} --member serviceAccount:terraform-serviceaccount@${GCP_PROJECT_ID}.iam.gserviceaccount.com --role roles/editor

# gcloud iam service-accounts keys create ~/.secret/gcloud/sakey.json \
  --iam-account terraform-serviceaccount@${GCP_PROJECT_ID}.iam.gserviceaccount.com
```

3.Get Azure Authentication Information
```
# az login
# az account list --query "[].{name:name, subscriptionId:id, tenantId:tenantId}"
```

4.Enter parameters and execute
```
# tee -a .bashrc <<_EOF_
# AWS ENV
export TF_VAR_access_key=AWS_ACCESSKEY
export TF_VAR_secret_key=AWS_SECRET_ACCESS_KEY
export TF_VAR_role_arn=AWS_RORLE_ARN
# Azure ENV
export ARM_SUBSCRIPTION_ID=subscriptionId
export ARM_CLIENT_ID=appId
export ARM_CLIENT_SECRET=password
export ARM_TENANT_ID=tenant
export ARM_ENVIRONMENT=public
# GCP ENV
GOOGLE_CLOUD_KEYFILE_JSON=~/.secret/gcloud/sakey.json
GOOGLE_CLOUD_PROJECT=${GCP_PROJECT_ID}
_EOF_
```
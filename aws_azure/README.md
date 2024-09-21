# Operating environment  
Ubuntu 24.04.1 LTS  
terraform 1.9.5    

# Usage  

## 1.Route53 zone registration with Shell script (run in Docker host)    
```
# cd /aws_azure
# sh/make_hosted_zone.sh yourdomain
```
## 2. Register NS of Route53 in NameServer  

## 3. TXT record issued by Let'sEncrypt (run in a separate terminal)  
```
# certbot certonly --manual -d yourdomain --preferred-challenges dns
```
## 4.Add TXT string to Route53  
```
# sh/letsencrypt_dns_setting.sh yourdomain _acme-challenge YOURSTRING
```
## 5.After reflecting TXT, press Enter on the Let's Encrypt issue screen to issue the certificate.  

## 6.Convert to pfx file  
```
# sh/makepfx.sh yourpfxfilename yourcertpasswd
```

## 7.Execution in Terraform  
```
# terraform init
# terraform plan
# terraform apply
```

If you get an error in terraform, try running terraform apply again.
# Usage  

## 1.Route53 zone registration with Shell script (run in Docker host)    
cd /aws_azure
sh/make_hosted_zone.sh yourdomain

## 2. Register NS of Route53 in NameServer of freenom  

## 3. TXT record issued by Let'sEncrypt (run in a separate terminal)  
certbot certonly --manual -d tohonokai.tk --preferred-challenges dns

## 4.Add TXT string to Route53  
sh/letsencrypt_dns_setting.sh yourdomain _acme-challenge YOURSTRING

## 5.After reflecting TXT, press Enter on the Let's Encrypt issue screen to issue the certificate.  

## 6.Convert to pfx file  
sh/makepfx.sh yourpfxfilename yourcertpasswd

## 7.Execution in Terraform  
terraform plan  
terraform apply

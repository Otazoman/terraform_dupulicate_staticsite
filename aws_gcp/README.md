# Usage  

## 1. Create a new domain in freenom  

## 2. terraform execution 
terraform apply

## 3.Shell script outputs NS.  
module.zone_acm.null_resource.get_ns_records (local-exec): *** Please Setting Yur Domain Nameserve ***  
module.zone_acm.null_resource.get_ns_records (local-exec): aaaa.awsdns-NN.co.uk.  
module.zone_acm.null_resource.get_ns_records (local-exec): bbb.awsdns-NN.net  
module.zone_acm.null_resource.get_ns_records (local-exec): cccc.awsdns-NN.com  
module.zone_acm.null_resource.get_ns_records (local-exec): ddd.awsdns-NN.org.  


## 4.Set the NS server output by Shell in the NameServer section of freenom. Set up in as short a time as possible.   

## 5.If CNAME authentication for ACM fails, run terraform again.  

Requires about 1 hour to complete construction
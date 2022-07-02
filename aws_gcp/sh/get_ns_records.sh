#!/bin/bash

if [ $# != 1 ]; then
    echo 'Empty CertName! Please [./get_ns_records.sh yourdomain]'
    exit 1
fi
domain=$1

route53result=$(aws route53 list-hosted-zones-by-name --dns-name ${domain} | jq -r ".HostedZones[0].Id")
hz=$(echo ${route53result} | sed -e "s!/hostedzone/!!g")
if [ "$hz" = "" ]; then
    echo 'Fail get HostedZoneId'
    exit 1
fi

echo '*** Please Setting Your Domain Nameserve ***'
route53records=$(aws route53 list-resource-record-sets --hosted-zone-id /hostedzone/${hz})
array=$(echo ${route53records} | \
        jq -c -r '.ResourceRecordSets[]| if .Type == "NS" then .ResourceRecords[].Value else empty end'
)
for i in ${array[@]}
do
  echo ${i}
done
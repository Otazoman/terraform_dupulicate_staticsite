#!/bin/bash

if [ $# != 1 ]; then
    echo 'Empty CertName! Please [./make_hosted_zone.sh yourdomain]'
    exit 1
fi
domain=$1

hostedzoneresult=$(aws route53 create-hosted-zone --name ${domain} --caller-reference `date +%Y-%m-%d_%H-%M-%S`)
route53result=$(aws route53 list-hosted-zones-by-name --dns-name ${domain} | jq -r ".HostedZones[0].Id")
HOSTED_ZONE_ID=$(echo ${route53result} | sed -e "s!/hostedzone/!!g")
if [ "${HOSTED_ZONE_ID}" = "" ]; then
    echo 'Fail get HostedZoneId'
    exit 1
fi

echo '*** Please Setting Your Domain Nameserve ***'
route53records=$(aws route53 list-resource-record-sets --hosted-zone-id /hostedzone/${HOSTED_ZONE_ID})
array=$(echo ${route53records} | \
        jq -c -r '.ResourceRecordSets[]| if .Type == "NS" then .ResourceRecords[].Value else empty end'
)
for i in ${array[@]}
do
  echo ${i}
done
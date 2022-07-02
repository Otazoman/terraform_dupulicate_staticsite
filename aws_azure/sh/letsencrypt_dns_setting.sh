#!/bin/bash

if [ $# != 3 ]; then
    echo 'Empty CertName! Please [./letsencrypt_dns_setting.sh yourdomain name string]'
    exit 1
fi
domain=$1
encryptname=$2
encryptstr=$3

route53result=$(aws route53 list-hosted-zones-by-name --dns-name ${domain} | jq -r ".HostedZones[0].Id")
HOSTED_ZONE_ID=$(echo ${route53result} | sed -e "s!/hostedzone/!!g")
if [ "${HOSTED_ZONE_ID}" = "" ]; then
    echo 'Fail get HostedZoneId'
    exit 1
fi
cat << EOF > createcnamerecode.json
{
     "Comment": "Creating Let'sEncrypt TXT record sets in Route 53",
     "Changes": [{
                "Action": "CREATE",
                "ResourceRecordSet": {
                            "Name": "${encryptname}.${domain}",
                            "Type": "TXT",
                            "TTL": 300,
                            "ResourceRecords": [{
                                      "Value": "\"${encryptstr}\""
                            }]
                }
    }]
}
EOF

aws route53 change-resource-record-sets --hosted-zone-id ${HOSTED_ZONE_ID} --change-batch file://createcnamerecode.json
rm createcnamerecode.json
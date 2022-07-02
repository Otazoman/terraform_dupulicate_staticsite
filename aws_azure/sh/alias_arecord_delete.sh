#!/bin/bash
SLEEP_TIME=10
BREAK_WORD="INSYNC"
JSON_FILE=`mktemp`

if [ $# != 1 ]; then
    echo 'Empty Domain! Please [./alias_arecord_delete.sh yourdomain]'
    exit 1
fi
domainname=$1

# Get Hostedzoneid
route53result=$(aws route53 list-hosted-zones-by-name --dns-name ${domainname})
hosted=$(echo ${route53result} | jq -r ".HostedZones[0].Id")
hz=$(echo ${hosted} | sed -e "s!/hostedzone/!!g")

# Route53 Make TargetRecords
route53records=$(aws route53 list-resource-record-sets --hosted-zone-id /hostedzone/${hz})
DELIMITA=","
RECTYPES=("A")

for (( i = 0; i < ${#RECTYPES[@]}; ++i )); do
if [ $i -gt 0  ]; then
  BODY+="$DELIMITA
  "
fi
route53alias=$(echo ${route53records} | jq -c -r '.ResourceRecordSets[] | if .Type == "'${RECTYPES[$i]}'" then .AliasTarget else empty end')
route53dnsname=$(echo ${route53records} | jq -c -r '.ResourceRecordSets[] | if .Type == "'${RECTYPES[$i]}'" then .Name else empty end')
RECORD_TYPE=${RECTYPES[$i]}
RESOURCE_VALUE=(`echo $route53alias`)
DNS_NAME=(`echo $route53dnsname`)

for (( j = 0; j < ${#RESOURCE_VALUE[@]}; ++j )); do
if [ $j -gt 0  ]; then
  BODY+="$DELIMITA"
fi
BODY+=$(cat <<EOS 
    {
      "Action": "DELETE",
      "ResourceRecordSet": {
        "Name": "${DNS_NAME[$j]}",
        "Type": "$RECORD_TYPE",
        "AliasTarget": ${RESOURCE_VALUE[$j]}
      }
    }
EOS
)
done
done
(
cat <<EOF
 {
    "Changes": [
    $BODY
  ]
}
EOF
) > $JSON_FILE

# Deleting DNS Record set
jobid=$(aws route53 change-resource-record-sets --hosted-zone-id ${hz} --change-batch file://$JSON_FILE)
JOBID=$(echo ${jobid} | jq -r ".ChangeInfo.Id" | sed -e "s!/change/!!g")

#Status check
while true
do
  sleep ${SLEEP_TIME}
  route53stat=$(aws route53 get-change --id /change/${JOBID})
  stat=$(echo ${route53stat} | jq -r ".ChangeInfo.Status")
  if [ "$stat"=${BREAK_WORD} ]; then
    break
  fi
done
echo "*** Setting Complete ***"
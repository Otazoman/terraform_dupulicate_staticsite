#!/bin/bash
SLEEP_TIME=30
STATUS_CODE="ACTIVE"

if [ $# != 1 ]; then
    echo 'Empty CertName! Please [./gcp_cert_check.sh certname]'
    exit 1
fi
domain=$1

# Check Cert status
certname=$(echo ${domain/./-})
echo "*** ssl cert status check ***"
while true
do
   echo "Check now please wait・・・"
   sleep ${SLEEP_TIME}
  naked_code=$(echo $(gcloud compute ssl-certificates describe ${certname}cert \
   --global \
   --format="get(managed.domainStatus)") | cut -d= -f2)
  www_code=$(echo $(gcloud compute ssl-certificates describe www${certname}cert \
   --global \
   --format="get(managed.domainStatus)") | cut -d= -f2)
  if [ "$naked_code" = "$STATUS_CODE" ] && [ "$www_code" = "$STATUS_CODE" ]; then
      break
  fi
done
echo "*** Setting Complete ***"
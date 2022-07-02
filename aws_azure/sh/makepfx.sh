#!/bin/bash

if [ $# != 3 ]; then
    echo 'Empty Filename! Please [./makepfx.sh domain filename password]'
    exit 1
fi
FILENAME=$1
FILENAME=$2
CERTPASSWD=$3
LEPATH=/etc/letsencrypt/live/${DOMAIN}

cd ./cert
openssl pkcs12 -export -out ${FILENAME}.pfx -inkey ${LEPATH}/privkey.pem -in ${LEPATH}/cert.pem -certfile ${LEPATH}/chain.pem -password pass:${CERTPASSWD}
ls -al ${FILENAME}.pfx
if [ $? -eq 0 ] ; then
   echo "${FILENAME}.pfx file make complete!"
   echo "Please execute terraform"
fi

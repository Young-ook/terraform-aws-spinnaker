#!/bin/bash -e
# create new self-signed certificate authority (CA)

CURDIR=`dirname $0`
CERT_HOME=$CURDIR/cert

# Variable
CNTRY="KR"
STAT="ICN"
LOC="ICN"
ORG="ORG"
CN="your@email.com"
GROUP="spinnaker-team1\nspinnaker-team2"

# Conditions
CLT=false
SVR=false

function print_usage() {
  echo "Usage: $0 -a(all) | -c(client only)"
}

function process_args() {
  if [[ $# < 1 ]]; then
    print_usage
    exit -1
  fi

  while [[ $# > 0 ]]; do
    local key="$1"
    shift
    case $key in
      -a)
        CLT=true
        SVR=true
        ;;
      -c)
        CLT=true
        SVR=false
        ;;
      *)
        >&2 echo "Unrecognized argument '$key'"
        exit -1
    esac
  done
}

function clean() {
  if [ -e $CERT_HOME ]; then
    if $CLT; then
      find "$CERT_HOME/" -name "client.*" -type f -delete
      find "$CERT_HOME/" -name "openssl.conf" -type f -delete
    fi

    if $CLT && $SVR; then
      rm -r "$CERT_HOME"
      mkdir -p "$CERT_HOME"
    fi
  else
    mkdir -p "$CERT_HOME"
  fi
}

function gen_ca() {
  openssl genrsa -out $CERT_HOME/ca.key 4096
  openssl req -new -x509 -days 365 -key $CERT_HOME/ca.key -out $CERT_HOME/ca.crt \
    -subj "/C=$CNTRY/ST=$STAT/L=$LOC/O=$ORG/OU=$ORG/CN=$CN"
}

function gen_server_crt() {
  openssl genrsa -out $CERT_HOME/server.key 4096
  openssl req -new -key $CERT_HOME/server.key -out $CERT_HOME/server.csr \
    -subj "/C=$CNTRY/ST=$STAT/L=$LOC/O=$ORG/OU=$ORG/CN=$CN"
 
  openssl x509 -req -days 365 -in $CERT_HOME/server.csr -CA $CERT_HOME/ca.crt -CAkey $CERT_HOME/ca.key \
    -CAcreateserial -out $CERT_HOME/server.crt

  echo "---------------------------------------------------------------------------"
  echo "Automatically generated key will be stored in $CERT_HOME/server.secret file"
  echo "---------------------------------------------------------------------------"
  # password auto-generation
  local PASSWD=$(pwgen 20 1)
  echo $PASSWD > $CERT_HOME/server.secret | chmod 600 $CERT_HOME/server.secret

  openssl pkcs12 -export -clcerts -in $CERT_HOME/server.crt \
    -inkey $CERT_HOME/server.key -out $CERT_HOME/server.p12 \
    -name spinnaker -password pass:$PASSWD

  keytool -keystore $CERT_HOME/keystore.jks -import -trustcacerts -alias ca \
    -file $CERT_HOME/ca.crt -storepass $PASSWD

  keytool -importkeystore \
    -srcalias spinnaker -srckeystore $CERT_HOME/server.p12 -srcstoretype pkcs12 \
    -srcstorepass $PASSWD \
    -destalias server -destkeystore $CERT_HOME/keystore.jks -deststoretype jks \
    -deststorepass $PASSWD -destkeypass $PASSWD
}

function gen_client_crt() {
  # x509 config file
cat << EOF > $CERT_HOME/openssl.conf
[ req ]
#default_bits		= 2048
#default_md		= sha256
#default_keyfile 	= privkey.pem
distinguished_name	= req_distinguished_name
req_extensions          = v3_req
x509_extensions         = v3_req

[ req_distinguished_name ]
countryName			= $CNTRY
countryName_min			= 2
countryName_max			= 2
stateOrProvinceName		= $STAT
localityName			= $LOC
0.organizationName		= $ORG
organizationalUnitName		= $ORG
commonName			= $CN
commonName_max			= 64
emailAddress			= Email Address
emailAddress_max		= 64

[ v3_req ]
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
1.2.840.10070.8.1 = ASN1:UTF8String:$GROUP
EOF

  openssl req -nodes -newkey rsa:2048 -keyout $CERT_HOME/client.key -out $CERT_HOME/client.csr \
    -subj "/C=$CNTRY/ST=$STAT/L=$LOC/O=$ORG/OU=$ORG/CN=$CN" -config $CERT_HOME/openssl.conf

  # create x509 certificates chain
  openssl x509 -req -days 365 -in $CERT_HOME/client.csr -out $CERT_HOME/client.crt \
    -CA $CERT_HOME/ca.crt -CAkey $CERT_HOME/ca.key -CAcreateserial \
    -extfile $CERT_HOME/openssl.conf -extensions v3_req
}

# main
process_args "$@"
clean

if $SVR && $CLT; then
  gen_ca
  gen_server_crt
fi

if $CLT; then
  gen_client_crt
fi

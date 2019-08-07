#!/bin/bash -e

# Environment
CURDIR=`dirname $0`
WORKDIR=$CURDIR/x509

# Variable
CNTRY=${country}
STAT=${state}
LOC=${location}
ORG=${organization}
CN=${common_name}
GROUP=${groups}

# Conditions
CLIENT=false
SERVER=false

# password auto-generation
PASSWD=$(pwgen 20 1)
echo $PASSWD

# print help
function print_usage() {
  echo "Usage: x509.sh --server_only | --client_only | --all"
}

# command parsing
function process_args() {
  if [[ $# < 1 ]]; then
    print_usage
    exit -1
  fi

  while [[ $# > 0 ]]; do
    local key="$1"
    shift
    case $key in
      --all)
        CLIENT=true
        SERVER=true
        ;;
      --server_only)
        CLIENT=false
        SERVER=true
        ;;
      --client_only)
        CLIENT=true
        SERVER=false
        ;;
      *)
        >&2 echo "Unrecognized argument '$key'"
        exit -1
    esac
  done
}

# clean up
function clean_up() {
  if [ -e $WORKDIR ]; then
    if $CLIENT; then
      find "$WORKDIR/" -name "client.*" -type f -delete
      find "$WORKDIR/" -name "openssl.conf" -type f -delete
    fi

    if $SERVER; then
      find "$WORKDIR/" -name "server.*" -type f -delete
      find "$WORKDIR/" -name "keystore.jks" -type f -delete
    fi

    if $CLIENT && $SERVER; then
      # remove the workspace
      rm -r "$WORKDIR"
      mkdir -p "$WORKDIR"
    fi
  else
    mkdir -p "$WORKDIR"
  fi
}

# create new self-signed certificate authority (CA) 
function create_ca() {
  echo "Create self signed certificates authority"

  openssl genrsa -out $WORKDIR/ca.key 4096
  openssl req -new -x509 -days 365 -key $WORKDIR/ca.key -out $WORKDIR/ca.crt \
    -subj "/C=$CNTRY/ST=$STAT/L=$LOC/O=$ORG/OU=$ORG/CN=$CN"
}

# create new server side certificates
function generate_server_cert() {
  openssl genrsa -out $WORKDIR/server.key 4096
  openssl req -new -key $WORKDIR/server.key -out $WORKDIR/server.csr \
    -subj "/C=$CNTRY/ST=$STAT/L=$LOC/O=$ORG/OU=$ORG/CN=$CN"
 
  openssl x509 -req -days 365 -in $WORKDIR/server.csr -CA $WORKDIR/ca.crt -CAkey $WORKDIR/ca.key \
    -CAcreateserial -out $WORKDIR/server.crt

  # Create server keystore
  openssl pkcs12 -export -clcerts -in $WORKDIR/server.crt \
    -inkey $WORKDIR/server.key -out $WORKDIR/server.p12 \
    -name spinnaker -password pass:$PASSWD

  keytool -keystore $WORKDIR/keystore.jks -import -trustcacerts -alias ca \
    -file $WORKDIR/ca.crt -storepass $PASSWD

  keytool -importkeystore \
    -srcalias spinnaker -srckeystore $WORKDIR/server.p12 -srcstoretype pkcs12 \
    -srcstorepass $PASSWD \
    -destalias server -destkeystore $WORKDIR/keystore.jks -deststoretype jks \
    -deststorepass $PASSWD -destkeypass $PASSWD
}

# create new client certificates
function generate_client_cert() {
  # x509 config file
cat << EOF > $WORKDIR/openssl.conf
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

  openssl req -nodes -newkey rsa:2048 -keyout $WORKDIR/client.key -out $WORKDIR/client.csr \
    -subj "/C=$CNTRY/ST=$STAT/L=$LOC/O=$ORG/OU=$ORG/CN=$CN" -config $WORKDIR/openssl.conf

  # create x509 certificates chain
  openssl x509 -req -days 365 -in $WORKDIR/client.csr -out $WORKDIR/client.crt \
    -CA $WORKDIR/ca.crt -CAkey $WORKDIR/ca.key -CAcreateserial \
    -extfile $WORKDIR/openssl.conf -extensions v3_req
}


### main 
process_args "$@"

clean_up

if $SERVER && $CLIENT; then
  create_ca
fi

if $SERVER; then
  generate_server_cert
fi

if $CLIENT; then
  generate_client_cert
fi

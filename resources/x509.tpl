#!/bin/bash -e

# Environment
CURDIR=`dirname $0`
SPIN_HOME=$CURDIR/spin

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
function cleanup() {
  if [ -e $WORKDIR ]; then
    if $CLIENT; then
      find "$SPIN_HOME/" -name "client.*" -type f -delete
      find "$SPIN_HOME/" -name "openssl.conf" -type f -delete
    fi

    if $SERVER; then
      find "$SPIN_HOME/" -name "server.*" -type f -delete
      find "$SPIN_HOME/" -name "keystore.jks" -type f -delete
    fi

    if $CLIENT && $SERVER; then
      # remove the workspace
      rm -r "$SPIN_HOME"
      mkdir -p "$SPIN_HOME"
    fi
  else
    mkdir -p "$SPIN_HOME"
  fi
}

# create new self-signed certificate authority (CA)
function create_ca() {
  echo "Create self signed certificates authority"

  openssl genrsa -out $SPIN_HOME/ca.key 4096
  openssl req -new -x509 -days 365 -key $SPIN_HOME/ca.key -out $SPIN_HOME/ca.crt \
    -subj "/C=$CNTRY/ST=$STAT/L=$LOC/O=$ORG/OU=$ORG/CN=$CN"
}

# create new server side certificates
function gen_server_crt() {
  openssl genrsa -out $SPIN_HOME/server.key 4096
  openssl req -new -key $SPIN_HOME/server.key -out $SPIN_HOME/server.csr \
    -subj "/C=$CNTRY/ST=$STAT/L=$LOC/O=$ORG/OU=$ORG/CN=$CN"
 
  openssl x509 -req -days 365 -in $SPIN_HOME/server.csr -CA $SPIN_HOME/ca.crt -CAkey $SPIN_HOME/ca.key \
    -CAcreateserial -out $SPIN_HOME/server.crt

  # password auto-generation
  local PASSWD=$(pwgen 20 1)
  echo $PASSWD > $SPIN_HOME/server.secret | chmod 600 $SPIN_HOME/server.secret

  # Create server keystore
  openssl pkcs12 -export -clcerts -in $SPIN_HOME/server.crt \
    -inkey $SPIN_HOME/server.key -out $SPIN_HOME/server.p12 \
    -name spinnaker -password pass:$PASSWD

  keytool -keystore $SPIN_HOME/keystore.jks -import -trustcacerts -alias ca \
    -file $SPIN_HOME/ca.crt -storepass $PASSWD

  keytool -importkeystore \
    -srcalias spinnaker -srckeystore $SPIN_HOME/server.p12 -srcstoretype pkcs12 \
    -srcstorepass $PASSWD \
    -destalias server -destkeystore $SPIN_HOME/keystore.jks -deststoretype jks \
    -deststorepass $PASSWD -destkeypass $PASSWD
}

# create new client certificates
function gen_client_crt() {
  # x509 config file
cat << EOF > $SPIN_HOME/openssl.conf
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

  openssl req -nodes -newkey rsa:2048 -keyout $SPIN_HOME/client.key -out $SPIN_HOME/client.csr \
    -subj "/C=$CNTRY/ST=$STAT/L=$LOC/O=$ORG/OU=$ORG/CN=$CN" -config $SPIN_HOME/openssl.conf

  # create x509 certificates chain
  openssl x509 -req -days 365 -in $SPIN_HOME/client.csr -out $SPIN_HOME/client.crt \
    -CA $SPIN_HOME/ca.crt -CAkey $SPIN_HOME/ca.key -CAcreateserial \
    -extfile $SPIN_HOME/openssl.conf -extensions v3_req
}


### main
process_args "$@"
cleanup

if $SERVER && $CLIENT; then
  create_ca
fi

if $SERVER; then
  gen_server_crt
fi

if $CLIENT; then
  gen_client_crt
fi

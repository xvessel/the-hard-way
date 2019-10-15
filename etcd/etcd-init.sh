#!/bin/bash
set -x
set -e

# https://superuser.com/questions/738612/openssl-ca-keyusage-extension
# https://www.openssl.org/docs/manmaster/man5/x509v3_config.html
# https://github.com/JW0914/Wikis/tree/master/Scripts%2BConfigs/OpenSSL

ETCD_HOME=/etc/kubernetes/etcd/
mkdir -p $ETCD_HOME
cd  $ETCD_HOME

days=365        # 证书有效期
ca_key="ca.key"    # 私钥
ca_crt="ca.crt"    # 证书
cn="etcd-ca"    # 签发机构

cp /etc/pki/tls/openssl.cnf ./
cat <<EOF >> ./openssl.cnf

[ etcd-ca-ext ]
keyUsage = critical, cRLSign, digitalSignature, keyEncipherment, keyCertSign
basicConstraints = critical,CA:true

[ etcd-server-ext ]
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = IP:127.0.0.1, IP:100.64.0.11

[ etcd-client-ext ]
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth

EOF



# 生成ca自签名证书
openssl req -x509 -nodes -newkey rsa:2048 -keyout ${ca_key} -out ${ca_crt} -days ${days} -subj "/CN=${cn}" \
            -config ./openssl.cnf -extensions etcd-ca-ext

function create_certificate(){ 
    name=$1
    subj=$2
    ext=$3
    key=${name}.key 
    csr=${name}.csr
    crt=${name}.crt 
    # create csr
    openssl req -nodes -newkey rsa:2048 -keyout ${key} -out ${csr} -subj "${subj}"
    
    # check csr
    #openssl req -noout -text -in ${csr}
    
    # create cst
    openssl x509 -req -days 3650 -in ${csr} -CA ${ca_crt} -CAkey ${ca_key}  -CAcreateserial -out ${crt} \
                 -extfile ./openssl.cnf -extensions ${ext}
    
    # check cst
    #openssl x509 -in ${crt} -noout -text

    rm ${csr}
    
}
create_certificate etcd-server "/O=system:masters/CN=kubernetes-admin" etcd-server-ext
create_certificate etcd-client "/O=system:masters/CN=kubernetes-admin" etcd-client-ext


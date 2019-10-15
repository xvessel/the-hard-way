#!/bin/bash
cd `dirname $0`

OUTPUT=/etc/kubernetes/pki
rm -rf $OUTPUT
mkdir -p $OUTPUT
cd ${OUTPUT}

# https://superuser.com/questions/738612/openssl-ca-keyusage-extension
# https://www.openssl.org/docs/manmaster/man5/x509v3_config.html
# https://github.com/JW0914/Wikis/tree/master/Scripts%2BConfigs/OpenSSL

set -x
set -e


cp /etc/pki/tls/openssl.cnf ./
cat <<EOF >> ./openssl.cnf

[ k8s-ca-ext ]
keyUsage = critical, cRLSign, digitalSignature, keyEncipherment, keyCertSign
basicConstraints = critical,CA:true

[ k8s-common-ext ]
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth


[ k8s-apiserver-ext ]
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = DNS:master, DNS:kubernetes.local, IP:127.0.0.1, IP:100.64.0.11, IP:10.32.0.1
EOF



days=365                     # 证书有效期
ca_key="${OUTPUT}/ca.key"    # 私钥
ca_crt="${OUTPUT}/ca.crt"    # 证书
cn="kubernetes"              # 签发机构

function create_certificate(){ 
    name=$1
    subj=$2
    ext=$3
    key=${OUTPUT}/${name}.key 
    csr=${OUTPUT}/${name}.csr
    crt=${OUTPUT}/${name}.crt 

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


# 生成ca自签名证书
openssl req -x509 -nodes -newkey rsa:2048 -keyout ${ca_key} -out ${ca_crt} -days ${days} -subj "/CN=${cn}" \
            -config ./openssl.cnf -extensions k8s-ca-ext

# The Admin Client Certificate (kubectl)
create_certificate admin "/O=system:masters/CN=kubernetes-admin" k8s-common-ext


#  Kubelet Client Certificates
create_certificate kubelet-node1 "/O=system:nodes/CN=system:node:node1" k8s-common-ext
create_certificate kubelet-node2 "/O=system:nodes/CN=system:node:node2" k8s-common-ext

# The Controller Manager Client Certificate
create_certificate kube-controller-manager "/O=system:kube-controller-manager/CN=system:kube-controller-manager" k8s-common-ext

# The Kube Proxy Client Certificate
create_certificate kube-proxy "/O=system:node-proxier/CN=system:kube-proxy" k8s-common-ext

# The Scheduler Client Certificate
create_certificate kube-scheduler "/O=system:kube-scheduler/CN=system:kube-scheduler" k8s-common-ext

# The Kubernetes API Server Certificat
export altname="DNS:kubernetes.com"
create_certificate kube-api-server "/CN=kube-apiserver" k8s-apiserver-ext

# The Service Account Key Pair
openssl genrsa -out sa.key 2048
openssl rsa -in sa.key -pubout -out sa.pub
openssl rsa -in sa.key -noout -text
openssl rsa -pubin -in sa.pub -noout -text

#

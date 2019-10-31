#!/bin/bash

set -x

K8S_PKI_ROOT_DIR='/etc/kubernetes/pki'
K8S_CA_FILE="${K8S_PKI_ROOT_DIR}/ca.crt"
K8S_CA_KEY_FILE="${K8S_PKI_ROOT_DIR}/ca.key"


# etcd
ETCD_ROOT_DIR='/etc/kubernetes/etcd'
ETCD_CA_FILE="${ETCD_ROOT_DIR}/ca.crt"
ETCD_CLIENT_CERT_FILE="${ETCD_ROOT_DIR}/etcd-client.crt"
ETCD_CLIENT_KEY_FILE="${ETCD_ROOT_DIR}/etcd-client.key"
ETCD_SERVERS='https://127.0.0.1:2379,https://127.0.0.1:12379,https://127.0.0.1:22379'

# APISERVER
APISERVER_INTERNAL_IP='100.64.0.11'
APISERVER_COUNT=1
APISERVER_CERT_FILE="${K8S_PKI_ROOT_DIR}/kube-api-server.crt"
APISERVER_KEY_FILE="${K8S_PKI_ROOT_DIR}/kube-api-server.key"
ADMIN_CERT_FILE="${K8S_PKI_ROOT_DIR}/admin.crt"
ADMIN_KEY_FILE="${K8S_PKI_ROOT_DIR}/admin.key"

# service account
SA_KEY_FILE="${K8S_PKI_ROOT_DIR}/sa.key"
SA_PUB_FILE="${K8S_PKI_ROOT_DIR}/sa.pub"

# k8s conf
K8S_CONF_ROOT_DIR='/etc/kubernetes/config'
CONTROLLER_KUBE_CONF="${K8S_CONF_ROOT_DIR}/kube-controller-manager.conf"
SCHEDULER_KUBE_CONF="${K8S_CONF_ROOT_DIR}/kube-scheduler.conf"

# k8s log dir
K8S_LOG_ROOT_DIR='/etc/kubernetes/log'
mkdir -p ${K8S_LOG_ROOT_DIR}

# start apiserver
nohup kube-apiserver \
  --advertise-address=${APISERVER_INTERNAL_IP} \
  --allow-privileged=true \
  --apiserver-count=${APISERVER_COUNT}\
  --audit-log-maxage=30 \
  --audit-log-maxbackup=3 \
  --audit-log-maxsize=100 \
  --audit-log-path=/var/log/audit.log \
  --authorization-mode=Node,RBAC \
  --bind-address=0.0.0.0 \
  --client-ca-file=${K8S_CA_FILE} \
  --enable-admission-plugins=NodeRestriction \
  --enable-bootstrap-token-auth=true \
  --etcd-cafile=${ETCD_CA_FILE} \
  --etcd-certfile=${ETCD_CLIENT_CERT_FILE} \
  --etcd-keyfile=${ETCD_CLIENT_KEY_FILE} \
  --etcd-servers=${ETCD_SERVERS} \
  --kubelet-certificate-authority=${K8S_CA_FILE} \
  --kubelet-client-certificate=${ADMIN_CERT_FILE} \
  --kubelet-client-key=${ADMIN_KEY_FILE} \
  --service-account-key-file=${SA_PUB_FILE} \
  --service-cluster-ip-range=10.32.0.0/24 \
  --service-node-port-range=30000-32767 \
  --tls-cert-file=${APISERVER_CERT_FILE} \
  --tls-private-key-file=${APISERVER_KEY_FILE} > ${K8S_LOG_ROOT_DIR}/apiserver.log 2>&1 &

# must wait apiserver init done
sleep 5

# start controller
nohup kube-controller-manager \
  --allocate-node-cidrs=true \
  --authentication-kubeconfig=${CONTROLLER_KUBE_CONF} \
  --authorization-kubeconfig=${CONTROLLER_KUBE_CONF} \
  --bind-address=127.0.0.1 \
  --client-ca-file=${K8S_CA_FILE} \
  --cluster-cidr=10.244.0.0/16 \
  --cluster-signing-cert-file=${K8S_CA_FILE} \
  --cluster-signing-key-file=${K8S_CA_KEY_FILE} \
  --controllers=*,bootstrapsigner,tokencleaner \
  --kubeconfig=${CONTROLLER_KUBE_CONF} \
  --leader-elect=true \
  --node-cidr-mask-size=24 \
  --root-ca-file=${K8S_CA_FILE} \
  --service-account-private-key-file=${SA_KEY_FILE} \
  --use-service-account-credentials=true > ${K8S_LOG_ROOT_DIR}/controller.log 2>&1 &

# start schduler
nohup kube-scheduler \
  --bind-address=127.0.0.1 \
  --kubeconfig=${SCHEDULER_KUBE_CONF} \
  --leader-elect=true > ${K8S_LOG_ROOT_DIR}/scheduler.log 2>&1 &

sleep 5

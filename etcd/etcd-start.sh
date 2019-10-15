#!/bin/bash
set -e
set -x

cd /etc/kubernetes/etcd


SERVER_CA_CERT='./ca.crt'
SERVER_CERT='./etcd-server.crt'
SERVER_KEY='./etcd-server.key'
PEER_CA_CERT='./ca.crt'
PEER_CERT='./etcd-server.crt'
PEER_KEY='./etcd-server.key'


function start_one_etcd(){
    ETCD_NAME=$1
    IP=$2
    PORT=$3
    PEER_PORT=$4
    PEERS=$5
    DATA_DIR=$6
    
    mkdir -p ${DATA_DIR}
    nohup etcd \
      --name ${ETCD_NAME} \
      --trusted-ca-file=${SERVER_CA_CERT} \
      --cert-file=${SERVER_CERT} \
      --key-file=${SERVER_KEY} \
      --peer-trusted-ca-file=${PEER_CA_CERT} \
      --peer-cert-file=${PEER_CERT} \
      --peer-key-file=${PEER_KEY} \
      --peer-client-cert-auth \
      --client-cert-auth \
      --initial-advertise-peer-urls https://${IP}:${PEER_PORT} \
      --listen-peer-urls https://${IP}:${PEER_PORT} \
      --listen-client-urls https://${IP}:${PORT},https://127.0.0.1:${PORT} \
      --advertise-client-urls https://${IP}:${PORT} \
      --initial-cluster-token etcd-cluster-0 \
      --initial-cluster  ${PEERS} \
      --initial-cluster-state new \
      --data-dir=${DATA_DIR} \
      --log-output stdout  > ${DATA_DIR}/etcd.log  2>&1 &

    
}


peers="etcd-0=https://127.0.0.1:2380,etcd-1=https://127.0.0.1:12380,etcd-2=https://127.0.0.1:22380,"

start_one_etcd "etcd-0" "127.0.0.1"  2379  2380 ${peers} "./etcd-data/etcd-0" 
start_one_etcd "etcd-1" "127.0.0.1" 12379 12380 ${peers} "./etcd-data/etcd-1" 
start_one_etcd "etcd-2" "127.0.0.1" 22379 22380 ${peers} "./etcd-data/etcd-2" 

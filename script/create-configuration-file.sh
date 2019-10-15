#!/bin/bash
set -x
set -e

PKI_DIR=/etc/kubernetes/pki
KUBERNETES_PUBLIC_ADDRESS='100.64.0.11'
OUTPUT=/etc/kubernetes/config
rm -rf ${OUTPUT}
mkdir -p ${OUTPUT}

ca_crt="${PKI_DIR}/ca.crt"
cluster_name="kubernetes-the-hard-way"

function create_config_file(){
  app_name=$1
  user_name=$1
  config_file_name=${OUTPUT}/${app_name}.conf
  app_key=${PKI_DIR}/${app_name}.key
  app_crt=${PKI_DIR}/${app_name}.crt

  kubectl config set-cluster ${cluster_name} \
    --certificate-authority=${ca_crt} \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${config_file_name}

  kubectl config set-credentials ${user_name} \
    --client-certificate=${app_crt} \
    --client-key=${app_key} \
    --embed-certs=true \
    --kubeconfig=${config_file_name}

  kubectl config set-context default \
    --cluster=${cluster_name} \
    --user=${user_name} \
    --kubeconfig=${config_file_name}

  kubectl config use-context default --kubeconfig=${config_file_name}
}

create_config_file admin
create_config_file kube-controller-manager
create_config_file kube-scheduler
create_config_file kube-proxy
create_config_file kubelet-node1
create_config_file kubelet-node2

mkdir -p ~/.kube
cp ${OUTPUT}/admin.conf ~/.kube/config

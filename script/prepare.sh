#!/bin/bash

 update system config
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system
sysctl net.bridge.bridge-nf-call-iptables=1
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
swapoff -a
systemctl stop firewalld
systemctl disable firewalld


# install docker
yum install -y docker
systemctl start docker
systemctl enable docker


# load images
docker load < /vagrant/download/images.tar

# copy bin file
cp /vagrant/download/bin/* /usr/bin/

# copy cni file
cp -r /vagrant/download/cni /opt/cni

mkdir -p /etc/kubernetes/pki
mkdir -p /etc/kubernetes/config
mkdir -p /etc/kubernetes/logs
mkdir -p /etc/kubernetes/etcd


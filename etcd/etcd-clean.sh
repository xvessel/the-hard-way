#!/bin/bash
set -x

#pkill etcd # todo, ansible will exit 1
rm /etc/kubernetes/etcd/*.crt
rm /etc/kubernetes/etcd/*.srl
rm /etc/kubernetes/etcd/*.nohup
rm /etc/kubernetes/etcd/*.key
rm -rf  /etc/kubernetes/etcd/etcd-data/*
exit 0

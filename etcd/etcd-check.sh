#!/bin/bash
set -e
set -x
cd /etc/kubernetes/etcd

sleep 5

ETCDCTL_API=3 etcdctl endpoint status -w table \
  --endpoints=https://127.0.0.1:2379,https://127.0.0.1:12379,https://127.0.0.1:22379\
  --cacert=./ca.crt \
  --cert=./etcd-client.crt \
  --key=./etcd-client.key \

ETCDCTL_API=3 etcdctl endpoint health -w table \
  --endpoints=https://127.0.0.1:2379,https://127.0.0.1:12379,https://127.0.0.1:22379\
  --cacert=./ca.crt \
  --cert=./etcd-client.crt \
  --key=./etcd-client.key \

ETCDCTL_API=3 etcdctl get / --prefix --keys-only \
  --endpoints=https://127.0.0.1:2379,https://127.0.0.1:12379,https://127.0.0.1:22379\
  --cacert=./ca.crt \
  --cert=./etcd-client.crt \
  --key=./etcd-client.key \


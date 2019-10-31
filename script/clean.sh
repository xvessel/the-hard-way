#!/bin/bash

# kill process
ps -ef | grep -v grep | grep -w 'kube-apiserver'          | awk '{print $2}' | xargs -I{} -r kill -9 {}
ps -ef | grep -v grep | grep -w 'kube-controller-manager' | awk '{print $2}' | xargs -I{} -r kill -9 {}
ps -ef | grep -v grep | grep -w 'kube-scheduler'          | awk '{print $2}' | xargs -I{} -r kill -9 {}
ps -ef | grep -v grep | grep -w 'kubelet'                 | awk '{print $2}' | xargs -I{} -r kill -9 {}
ps -ef | grep -v grep | grep -w 'kube-proxy'              | awk '{print $2}' | xargs -I{} -r kill -9 {}

rm -rf /etc/kubernetes/config
rm -rf /etc/kubernetes/pki
rm -rf /etc/kubernetes/logs
rm -rf /var/lib/kubelet
rm -rf /etc/cni/net.d
docker ps -aq | xargs -r -I{} docker rm -f {}

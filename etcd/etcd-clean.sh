#!/bin/bash
set -x

ps -ef | grep -v grep | grep -w '/usr/bin/etcd' | awk '{print $2}' | xargs -I{} -r kill -9 {}
rm  -rf /etc/kubernetes/etcd/
exit 0

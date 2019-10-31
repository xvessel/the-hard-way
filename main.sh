#!/bin/bash
rm -rf ./config
rm -rf ./pki
ansible-playbook play-etcd.yml  -i hosts -vvv
ansible-playbook play-k8s.yml  -i hosts -vvv

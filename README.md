# the hard way

参考[kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way), 去掉了许多与公有云相关的操作，使用vagrant+virtualbox+ansible的方式手动部署k8s.

## 准备工作

- 1. 安装virtualbox
- 2. 安装vagrant
- 3. 安装ansible
- 4. 下载所需资源

todo, 将以下文件上传到对象存储。

- 手动编译好的k8s bin文件，
- 下载好的docker image文件
- cni文件


## start

- 1. 启动虚拟机： `vagrant up`
- 2. 部署etcd集群：  ansible-playbook play-etcd.yml -i hosts -v
- 3. 部署k8s集群：  ansible-playbook play-k8s.yml -i hosts -v
- 4. 清理： `vagrant destroy`


TODO:
- 1. fix node to apiserver clusterrolebiding
- 2. fix apiserver to node: cert unknown author
- 3. upload core-dns image

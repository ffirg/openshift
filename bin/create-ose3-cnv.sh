#!/bin/bash

export PATH=$PATH:.

APP=""
SRC=""
DEMO_USER="system"
DEMO_USER_PW="admin"
PROJECT="container-vm"
IMAGE="centos/httpd-24-centos7"
DESC="Container Native Virtualisation"
VERSION="v0.4.1"
OS="`uname -s | tr '[A-Z]' '[a-z]'`"
ARCH="`uname -p | tr '[A-Z]' '[a-z]'`"
KUBECTL_URL="https://storage.googleapis.com/kubernetes-release/release/v1.10.3/bin/${OS}/${ARCH}/kubectl"
VIRTCTL_URL="https://github.com/kubevirt/kubevirt/releases/download/$VERSION/virtctl-$VERSION-${OS}-amd64"
KUBECTL="kubectl"
VIRTCTL="virtctl"
build_status="NULL"

# include all our functions...
. ../libs/functions

# START
echo
echo "EXAMPLE VM RUN INSIDE AN OPENSHIFT CONTAINER!!!"
echo

run_cmd echo "First login into OSE..."
run_cmd run "oc login -u $DEMO_USER -p $DEMO_USER_PW"


# need kubectl CLI binary
if [ ! -x $KUBECTL ]
then
  curl -Lk -o $KUBECTL https://storage.googleapis.com/kubernetes-release/release/v1.10.3/bin/linux/amd64/kubectl && chmod +x $KUBECTL
fi

kubectl create     -f https://github.com/kubevirt/kubevirt/releases/download/$VERSION/kubevirt.yaml
oc adm policy add-scc-to-user privileged system:serviceaccount:kube-system:kubevirt-privileged
oc adm policy add-scc-to-user privileged system:serviceaccount:kube-system:kubevirt-controller
oc adm policy add-scc-to-user privileged system:serviceaccount:kube-system:kubevirt-infra
oc apply -f https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt.yaml

# need virtclt CLI binary
if [ ! -x $VIRTCTL ]
then
  curl -Lk -o $VIRTCTL https://github.com/kubevirt/kubevirt/releases/download/$VERSION/virtctl-$VERSION-linux-amd64 && chmod +x $VIRTCTL
fi

# setup project
run_cmd echo "Setup the $PROJECT project"
run_cmd run "oc new-project $PROJECT --description \"$DESC\""
run_cmd run "oc project $PROJECT"

kubectl apply -f https://raw.githubusercontent.com/kubevirt/demo/master/manifests/vm.yaml
kubectl get vms testvm -o yaml | grep "phase:" 
virtctl start testvm
kubectl get vms
virtctl console testvm


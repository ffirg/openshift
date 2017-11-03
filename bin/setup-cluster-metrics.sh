#!/usr/bin/env bash

#
# Setup OSE cluster metrics for centralised logging
# This is a pre requisite for CPU auto-scaling :)
#

OSE_MASTER="192.168.99.100"
LIBDIR="../libs"
CONFDIR="../conf"
USER="demo"
MDSA="metrics-deployer-service-account.yml"
PROJECT="openshift-infra"

. ${LIBDIR}/functions

# START
echo
echo "*** SETUP OPENSHIFT CLUSTER METRICS ***"
echo "*** THIS USES AUTO GENERATED CERTS AND NON-PERSISTENT METRICS STORAGE ***"
echo

# Need to run as root so we are SYSTEM:ADMIN
if [ ${MY_UID} -ne 0 ]
then
  echo "Need to be root for this one!"
  exit 1
fi

run_cmd echo "Creating ${PROJECT} project..."
run_cmd run "oc new-project ${PROJECT}"
run_cmd echo "Log in to the ${PROJECT} project..."
run_cmd run "oc project ${PROJECT}"

if [ ! -r ${CONFDIR}/${MDSA} ]
then
  echo "Whoops! ${MDSA} is missing :("
  echo "Creating a sample one ..."
  mkdir ${CONFDIR} >/dev/null 2>&1
  cat > ${CONFDIR}/${MDSA} <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: metrics-deployer
secrets:
- name: metrics-deployer
EOF
  chown -R demo:demo ${CONFDIR} >/dev/null 2>&1
  chmod 755 ${CONFDIR} >/dev/null 2>&1
  chmod 644 ${CONFDIR}/${MDSA} >/dev/null 2>&1
fi

run_cmd echo "Creating Metrics Deployer Service Account..."
run_cmd run "oc create -f ${CONFDIR}/${MDSA}"

run_cmd echo "Grant correct permissions to accounts..."
run_cmd run "oadm policy add-role-to-user edit system:serviceaccount:openshift-infra:metrics-deployer"
run_cmd run "oadm policy add-cluster-role-to-user cluster-reader system:serviceaccount:openshift-infra:heapster"

# uncomment the following to use your own certs
#oc secrets new metrics-deployer hawkular-metrics.pem=/home/openshift/metrics/hm.pem \
#hawkular-metrics-ca.cert=/home/openshift/metrics/hm-ca.cert

# else you can use the default auto-generated certs...
run_cmd echo "Use auto-generated certs for trust..."
run_cmd run "oc secrets new metrics-deployer nothing=/dev/null"

METRICS="metrics.yaml"
METRICS_TEMPLATE="/usr/share/ansible/openshift-ansible/roles/openshift_examples/files/examples/infrastructure-templates/enterprise/metrics-deployer.yaml"

echo "Ensuring we have a metrics config file..."
if [ ! -r ${CONFDIR}/{METRICS} ]
then
  if [ -r ${METRICS_TEMPLATE} ]
  then
    cp ${METRICS_TEMPLATE} ${CONFDIR}/${METRICS}
  fi
fi

run_cmd echo "Setting up Hawkular metrics...this will run for some time in the background..."
run_cmd run "oc process -f ${CONFDIR}/${METRICS} -v IMAGE_PREFIX=openshift3/,IMAGE_VERSION=latest,HAWKULAR_METRICS_HOSTNAME=${OSE_MASTER},USE_PERSISTENT_STORAGE=false | oc create -f -"

OSE_MASTER_CONFIG=/etc/origin/master/master-config.yaml
TIMESTAMP="`date +%d%m%y_%m%S`"

echo "Updating OSE Master Config (adding Metrics URL...)"
if [ -r ${OSE_MASTER_CONFIG} ]
then
  grep "metricsPublicURL:" ${OSE_MASTER_CONFIG} >/dev/null 2>&1 || \
  ( cp ${OSE_MASTER_CONFIG} ${OSE_MASTER_CONFIG}.${TIMESTAMP} && \
    echo "Made a copy of master file - ${OSE_MASTER_CONFIG}.${TIMESTAMP}" && \
   sed -i '/assetConfig:/a\ \ metricsPublicURL: https://'"${OSE_MASTER}"'/hawkular/metrics' ${OSE_MASTER_CONFIG} )
fi

echo "Restating Openshift Master..."
systemctl restart atomic-openshift-master 

echo "WE SHOULD BE DONE HERE!"

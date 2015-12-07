#!/usr/bin/bash

#
# Setup OSE centralised container logs using EFK
#

OSE_MASTER="openshift.example.com"
LIBDIR="../libs"
CONFDIR="../conf"
USER="demo"
LDSA="logging-deployer-service-account.yml"
PROJECT="logging"

. ${LIBDIR}/functions

# START
echo
echo "*** SETUP CENTRALISED OPENSHIFT EFK LOGGING ***"
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

run_cmd echo "Setting up deployer secrets (ssshhhh...)"
run_cmd run "oc secrets new logging-deployer kibana.crt=../conf/kibana.crt kibana.key=../conf/kibana.key"

if [ ! -r ${CONFDIR}/${LDSA} ]
then
  echo "Whoops! ${LDSA} is missing :("
  echo "Creating a sample one ..."
  mkdir ${CONFDIR} >/dev/null 2>&1
  cat > ${CONFDIR}/${LDSA} <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: logging-deployer
secrets:
- name: logging-deployer
EOF
  chown -R demo:demo ${CONFDIR} >/dev/null 2>&1
  chmod 755 ${CONFDIR} >/dev/null 2>&1
  chmod 644 ${CONFDIR}/${LDSA} >/dev/null 2>&1
fi

run_cmd echo "Creating Logging Deployer Service Account..."
run_cmd run "oc create -f ${CONFDIR}/${LDSA}"

run_cmd echo "Grant correct permissions to accounts..."
run_cmd run "oc policy add-role-to-user edit system:serviceaccount:logging:logging-deployer"

echo "Run use command -> oc edit scc/privileged"
echo "And add this line to the service accounts:"
echo "- system:serviceaccount:logging:aggregated-logging-fluentd"
read x

run_cmd run "oadm policy add-cluster-role-to-user cluster-reader system:serviceaccount:logging:aggregated-logging-fluentd"


LOGGING="logging.yaml"
LOGGING_TEMPLATE="/usr/share/ansible/openshift-ansible/roles/openshift_examples/files/examples/infrastructure-templates/enterprise/logging-deployer.yaml"

echo "Ensuring we have a logging config file..."
if [ ! -r ${CONFDIR}/{LOGGING} ]
then
  if [ -r ${LOGGING_TEMPLATE} ]
  then
    cp ${LOGGING_TEMPLATE} ${CONFDIR}/${LOGGING}
  fi
fi

run_cmd echo "Setting up logging deployer using a template..."
run_cmd run "oc create -n openshift -f ${CONFDIR}/${LOGGING}"

run_cmd echo "Run the deployer (this will take some time to complete in the background)..."
run_cmd run "oc process logging-deployer-template -n openshift -v KIBANA_HOSTNAME=kibana.example.com,ES_CLUSTER_SIZE=1,PUBLIC_MASTER_URL=https://localhost:8443 | oc create -f -"

echo "Once the deployer completes, run this command:"
echo "oc process logging-support-template | oc create -f -"

#!/usr/bin/bash

ADMIN_USER="system:admin"
build_status="NULL"
LIBDIR="../libs"
CONFDIR="../conf"
QUOTA="resource-quota.json"
USER="demo"

. ${LIBDIR}/functions

# START
echo
echo "*** APPLY A RESOURCE QUOTA TO A PROJECT ***"
echo

# Need to run as root so we are SYSTEM:ADMIN
if [ ${MY_UID} -ne 0 ]
then
  echo "Need to be root for this one!"
  exit 1
fi

# Login as a user with cluster admin rights
run_cmd echo "Login as a system admin user..."
run_cmd run "oc login -u ${ADMIN_USER}"
echo
echo "Choose a project to assign the quotas to: "
echo "${OC_PROJECTS}"
echo
echo -n "Enter project name: "
read PROJECT

run_cmd echo "Log in to project..."
run_cmd run "oc project ${PROJECT}"

if [ ! -r ${CONFDIR}/${QUOTA} ]
then
  echo "Whoops! ${QUOTA} is missing :("
  echo "Creating a sample one for test purposes..."
  mkdir ${CONFDIR} >/dev/null 2>&1
  cat > ${CONFDIR}/${QUOTA} << EOF
{
  "apiVersion": "v1",
  "kind": "ResourceQuota",
  "metadata": {
    "name": "quota"
  },
  "spec": {
    "hard": {
      "memory": "1Gi",
      "cpu": "20",
      "pods": "4",
      "services": "5",
      "replicationcontrollers":"5",
      "resourcequotas":"1"
    }
  }
}
EOF
  chown -R demo:demo ${CONFDIR} >/dev/null 2>&1
  chmod 755 ${CONFDIR} >/dev/null 2>&1
  chmod 644 ${CONFDIR}/${QUOTA} >/dev/null 2>&1
fi

run_cmd echo "Apply resource quota..."
run_cmd run "oc create -f ${CONFDIR}/${QUOTA}"

# Show quotas applied 
run_cmd echo "Here's the quota applied:"
run_cmd run "oc get quota"

run_cmd echo "You can see the quotas set under Settings in the GUI"

run_cmd echo "Now let's remove them..."
run_cmd run "oc delete -f ${CONFDIR}/${QUOTA}"

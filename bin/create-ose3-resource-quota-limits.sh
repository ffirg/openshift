#!/usr/bin/bash

ADMIN_USER="system:admin"
build_status="NULL"
LIBDIR="../libs"
CONFDIR="../conf"
QUOTA="resource-quota.json"
LIMITS="resource-limits.json"
USER="developer"

. ${LIBDIR}/functions

# START
echo
echo "*** APPLY A RESOURCE QUOTA AND LIMITS TO A PROJECT ***"
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

run_cmd echo "Apply resource quota for the PROJECT..."
run_cmd run "oc create -f ${CONFDIR}/${QUOTA}"

# Show quotas applied 
run_cmd echo "Here's the quota applied:"
run_cmd run "oc get quota"

run_cmd echo "Now apply resource limits for PODS/CONTAINERS..."
run_cmd run "oc create -f ${CONFDIR}/${QUOTA}"

run_cmd echo "You can see the quotas and limits set under Resources->Quota in the GUI"

run_cmd echo "Now let's remove them..."
run_cmd run "oc delete -f ${CONFDIR}/${QUOTA}"

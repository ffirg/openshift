#!/usr/bin/bash

export APP="myapp"
DEMO_USER="demo"
build_status="NULL"
PROJECT="demo"
QUOTA="resource-quota.json"
USER="demo"

. ../lib/functions

# START
echo
echo "*** APPLY A RESOURCE QUOTA TO A PROJECT ***"
echo

#
# DO WE NEED TO BE SYSTEM:ADMIN???
# OR ADD WE MAKE DEMO USER CLUSTER ADMIN
#

# Login as a user with cluster admin rights
echo "Login as a cluster admin user"
#run_cmd run "oc login -u $USER"

# select project to apply the quotas to
# default=demo?
# read ans here

echo "What project do you want to apply the quotas to ?"
read x
#run_cmd run "oc project ${PROJECT}"


if [ -r $QUOTA ]
then
  oc create -f ${QUOTA}
else
  # could create one here with HEREIS doc...
  echo "Whoops! ${QUOTA} is missing :("
  exit 1
fi

# Show quotas applied 
run_cmd echo "Here's the quotas applied:""
run_cmd run "oc get quota"


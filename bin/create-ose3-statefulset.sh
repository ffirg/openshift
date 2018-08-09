#!/bin/bash

APP="mehdb"
STS="mehdb"
PROJECT="mehdb"
DEMO_USER="developer"
build_status="NULL"

# include all our functions...
. ../libs/functions

cleanup () {
  oc delete sts ${STS} -n ${PROJECT} 2>/dev/null 
  oc delete pvc -n ${PROJECT} --all 2>/dev/null
  oc delete svc ${APP} -n ${PROJECT} 2>/dev/null
  oc delete route ${APP} -n ${PROJECT} 2>/dev/null
  exit
}

if [ $1 = "cleanup" ]
then
  cleanup
fi

# START
echo
echo "KUBERNETES STATEFULSET EXAMPLE FOR USE WITH MINISHIFT"
echo

run_cmd echo "First login into OSE (as $DEMO_USER user)..."
run_cmd run "oc login -u $DEMO_USER"

# setup project
run_cmd echo "Setup the $PROJECT project"
run_cmd run "oc new-project $PROJECT --description \"Statefulset Example\""
run_cmd run "oc project $PROJECT"

run_cmd echo "Git clone from the example repo..."
git clone https://github.com/ffirg/mehdb.git && cd mehdb

run_cmd echo "Insert the config using oc apply..."
run_cmd run "oc apply -f app.yaml -n ${PROJECT}"

run_cmd echo "Let's log into a container and inject some sample data..."
run_cmd run "oc rsh mehdb-0"
echo "test data" > /tmp/test
curl -L -XPUT -T /tmp/test mehdb:9876/set/test
curl mehdb:9876/get/test
curl mehdb-1.mehdb:9876/get/test

# run_cmd echo "We can scale up (& down) the service..."
# run_cmd run "oc scale -n ${PROJECT} sts ${STS} --replicas=4"

# run_cmd echo "Let's expose the service so it's accessible..."
# run_cmd run "oc expose service $APP"

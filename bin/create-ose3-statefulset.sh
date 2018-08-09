#!/bin/bash

# example coded the most excellent blog by Michael Hausenblas https://goo.gl/C9g356

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
  oc delete project ${PROJECT} 2>/dev/null
  rm -rf ${APP} 2>/dev/null
  exit
}

if [ "$1" = "cleanup" ]
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

run_cmd echo "Let's expose the service so it's accessible..."
run_cmd run "oc expose service $APP"

pod_status="`oc get pods -n mehdb | grep ${APP}-0 | awk '{print $3}'`"
  until [ $pod_status = "Running" ]
  do
    echo "Waiting for pod to be running..."
    sleep 5
    pod_status="`oc get pods -n mehdb | grep ${APP}-0 | awk '{print $3}'`"
  done

run_cmd echo "Let's log into a container and inject some sample data..."
oc rsh mehdb-0 <<EOF
echo "THIS IS TEST DATA FROM FILE /tmp/test" > /tmp/test
curl -L -XPUT -T /tmp/test mehdb:9876/set/test
EOF

run_cmd echo "We can scale up (& down) the service..."
run_cmd run "oc scale -n ${PROJECT} sts ${STS} --replicas=4"

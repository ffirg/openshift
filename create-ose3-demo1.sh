#!/usr/bin/bash

# function to do the grunt work, step by step
run_cmd () {
 if [ $1 = "echo" ]
 then
   shift
   action="$*"
   echo $action
   read x 
 elif [ $1 = "run" ]
 then
   shift
   action="$*"
   echo $action
   eval $action
   echo
 fi
}

if [ ! $1 ]
then
  project=openshift-demo1
else
  project=$1
fi

# START
echo
echo "WE'LL CREATE A NEW SAMPLE OPENSHIFT v3 APP"
echo "Buckle up and hold on tight please..."
echo

echo "Have you logged into OSE as a project user?"
read x

#git clone https://github.com/openshift/origin.git
cd ~/origin/examples/sample-app
#./pullimages.sh

run_cmd echo "CREATE NEW PROJECT CALLED $project"
run_cmd run "oc new-project $project --display-name=\"Openshift3 Demo 1\" --description=\"Demo of Ruby and MySQL Multi-tier\""

run_cmd echo "ADD USER PHIL AS ADMIN"
run_cmd run "oadm policy add-role-to-user admin phil $project"

run_cmd echo "CREATE NEW APP FROM TEMPLATE"
run_cmd run "oc new-app application-template-stibuild.json"

run_cmd echo "BUILD SHOULD BE RUNNING NOW. LET'S CHECK:"
run_cmd run "oc get builds"

run_cmd echo "LET'S CHECK THE LOG..."
run_cmd run "oc build-logs ruby-sample-build-1"

run_cmd echo "ONCE BUILT, IMAGE WILL GO INTO LOCAL REGISTRY:"
run_cmd run "oc describe service docker-registry --config=/etc/openshift/master/admin.kubeconfig | grep -E 'Name:|IP:'"

run_cmd echo "YOU CAN USE DOCKER COMMANDS AS WELL"
run_cmd run "docker images | grep ruby-sample"

run_cmd echo "=== EVERYTHING SHOULD BE DONE NOW ==="

run_cmd echo "LET'S CHECK EVERYTHING..."

run_cmd echo "SERVICES:"
run_cmd run "oc get services"

run_cmd echo "ROUTES:"
run_cmd run "oc get routes"

run_cmd echo "PODS:"
run_cmd run "oc get pods"

run_cmd echo "LET'S SCALE UP THE FRONT END SERVICE..."
run_cmd run "oc scale --replicas=3 replicationcontrollers frontend-1"

run_cmd echo "...AND SCALE BACK JUST FOR FUN..."
run_cmd run "oc scale --replicas=1 replicationcontrollers frontend-1"

run_cmd echo "TO CLEAN UP AND DESTROY THE PROJECT, run 'oc delete project $project'"

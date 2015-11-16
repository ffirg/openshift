#!/usr/bin/bash

export APP1="app-a"
export APP2="app-b"
DEMO_USER="demo"
PROJECT="abdeployment"
SRC="https://github.com/ffirg/ab-deploy.git"
LABELS="abgroupmember=true"
build_status="NULL"
pods=4

# function to do the grunt work, step by step
run_cmd () {
 if [ $1 = "echo" ]
 then
   shift
   action="$*"
   echo $action
   echo "<RETURN> when ready"
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

# function to wait until build has completed before proceeding further
check_build () {
  build_status="`oc get builds | grep ${1}-1 | awk '{print $3}'`"
  while true
  do
    if [ -z $build_status ]
    then
      echo "Whoops! There is no build image, something went wrong :("
      exit 99
    else
      until [ $build_status = "Complete" ]
      do
        echo "$1 build is still $build_status..."
        sleep 10
        build_status="`oc get builds | grep ${1}-1 | awk '{print $3}'`"
      done
    fi
    echo "$1 build is DONE!"
    echo
    break
  done
}

# START
echo
echo "EXAMPLE OPENSHIFT v3 APP A-B ROLLING DEPLOYMENT"
echo "*** BEFORE STARTING ENSURE APP IS VERSION ONE on $SRC ***"
echo

run_cmd echo "First login into OSE (as $DEMO_USER user)..."
run_cmd run "oc login -u $DEMO_USER"

# setup project
run_cmd echo "Setup the $PROJECT project"
run_cmd run "oc new-project $PROJECT --description \"Rolling A-B Deployment\""
run_cmd run "oc project $PROJECT"

# do some dev work!
run_cmd echo "Create new app - call it the \"$APP1\" service"
run_cmd run "oc new-app $SRC --name=$APP1 --labels=$LABELS"

# wait until the build is finished before going on...
check_build $APP1

run_cmd echo "This is the build log..."
run_cmd run "oc build-logs ${APP1}-1"

run_cmd echo "Check out the service name:"
run_cmd run "oc get svc"

run_cmd echo "We have no route, so the service isn't exposed:"
run_cmd run "oc get route"

run_cmd echo "Let's expose \"VERSION 1\" of $APP1"
run_cmd run "oc expose dc/$APP1 --name=ab-service --selector=abgroupmember=true --generator=service/v1"

run_cmd echo "We now have TWO services:"
run_cmd run "oc get svc"

run_cmd echo "Let's expose a route for the new service:"
run_cmd run "oc expose service ab-service --name=ab-route --hostname=abdeploy.example.com"

run_cmd echo "Let's now scale up the service, to cope with more incoming load..."
oc scale dc/$APP1 --replicas=$pods

run_cmd echo "We should now have $pods pods running..."
run_cmd run "oc get pods"

run_cmd echo "We have check what we're hitting with a simple curl test:"
for i in {1..10}; do curl abdeploy.example.com; echo " "; done

# Make change to source code...
run_cmd echo "GO MAKE A CHANGE TO THE SOURCE CODE - MAKE IT VERSION 2..."

run_cmd echo "Create another app - call it \"$APP2\" but use the SAME service label:"
run_cmd run "oc new-app $SRC --name=$APP2 --labels=$LABELS"

# wait until the build is finished before going on...
check_build $APP2

run_cmd echo "Check again the number of pods running..."
run_cmd run "oc get pods"

run_cmd echo "and do the curl test again:"
for i in {1..10}; do curl abdeploy.example.com; echo " "; done

run_cmd echo "Now let's scale down $APP1 and $APP2 up..."
run_cmd run "oc scale dc/$APP1 --replicas=2"
run_cmd run "oc scale dc/$APP2 --replicas=2"

run_cmd echo "The curl test again:"
for i in {1..10}; do curl abdeploy.example.com; echo " "; done

run_cmd echo "Version 2 looks great, so let's rolls that out and retire version 1..."
run_cmd run "oc scale dc/$APP1 --replicas=0"
run_cmd run "oc scale dc/$APP2 --replicas=4"

run_cmd echo "We're now running only VERSION 2:"
for i in {1..10}; do curl abdeploy.example.com; echo " "; done

# THE END

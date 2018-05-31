#!/usr/bin/env bash

export APPNAME="ab-demo-app"
APPv1="version=1"
APPv2="version=2"
DEMO_USER="developer"
PROJECT="abdeployment"
SRC="https://github.com/ffirg/ab-deploy.git"
NAME="abdeploy.192.168.99.100.xip.io"
LABELS="versioning=true"
build_status="NULL"
pods=4

# include all our functions...
. ../libs/functions

# START
echo
echo "EXAMPLE OPENSHIFT v3 APP A-B ROLLING DEPLOYMENT"
echo "*** BEFORE STARTING ENSURE APP IS VERSION ONE on $SRC ***"
echo

run_cmd echo "First login into OSE (as $DEMO_USER user)..."
run_cmd run "oc login -u $DEMO_USER"

# setup project
run_cmd echo "Setup the $PROJECT project"
run_cmd run "oc new-project $PROJECT --description \"Rolling A-B Deployment Example\""
run_cmd run "oc project $PROJECT"

# do some dev work!
run_cmd echo "Create new app - let's call it \"$APPNAME\""
run_cmd run "oc new-app $SRC --name=${APPNAME} --labels=$APPv1"

# wait until the build is finished before going on...
check_build ${APPNAME}

run_cmd echo "Let's expose a route for the new service:"
VERSION="v1"
run_cmd run "oc expose service ${APPNAME} --name=${APPNAME}-${VERSION}"

run_cmd echo "Let's now scale up the service, to cope with more incoming load..."
oc scale dc/${APPNAME} --replicas=$pods

run_cmd echo "We should now have $pods pods running..."
run_cmd run "oc get pods"

run_cmd echo "We can check what we're hitting with a simple curl test:"
for i in {1..10}; do curl `oc get route|grep "${APPNAME}-${VERSION}"|awk '{print $2}'`; echo " "; done

# Make change to source code...
echo
run_cmd echo "GO MAKE A CHANGE TO THE SOURCE CODE @ ${SRC} and change VERSION 1 to VERSION 2 in index.php"

#run_cmd echo "Create a new version of our app..."
VERSION="v2"
run_cmd run "oc new-app $SRC --name=${APPNAME}-${VERSION} --labels=$APPv2"

# wait until the build is finished before going on...
check_build ${APPNAME}-${VERSION}

run_cmd echo "Check again the number of pods running..."
run_cmd run "oc get pods"

run_cmd echo "Let's expose a second route for the new version:"
#run_cmd run "oc expose service ${APPNAME}-v2 --name=${APPNAME}-v2 --hostname=v2.${NAME}"
run_cmd run "oc expose service ${APPNAME}-${VERSION} --name=${APPNAME}-${VERSION}"

run_cmd echo "and do the curl test again:"
#for i in {1..10}; do curl v2.${NAME}; echo " "; done
for i in {1..10}; do curl `oc get route|grep "${APPNAME}-${VERSION}"|awk '{print $2}'`; echo " "; done

run_cmd echo "Now let's scale down $APPv1 and $APPv2 up..."
run_cmd run "oc scale dc/${APPNAME} --replicas=2"
run_cmd run "oc scale dc/${APPNAME}-v2 --replicas=2"

run_cmd echo "The curl test again:"
#for i in {1..10}; do curl v1.${NAME}; echo " "; done
#for i in {1..10}; do curl v2.${NAME}; echo " "; done
for i in {1..10}; do curl `oc get route|grep "${APPNAME}"|awk '{print $2}'`; echo " "; done

run_cmd echo "Version 2 looks great, so let's rolls that out and retire version 1..."
run_cmd run "oc scale dc/${APPNAME} --replicas=0"
run_cmd run "oc scale dc/${APPNAME}-v2 --replicas=4"

run_cmd echo "We're now running only VERSION 2:"
#for i in {1..10}; do curl v2.${NAME}; echo " "; done
for i in {1..10}; do curl `oc get route|grep "${APPNAME}"|awk '{print $2}'`; echo " "; done

# THE END

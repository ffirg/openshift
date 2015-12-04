#!/usr/bin/bash

FE_APP="openshift3mlbparks"
DB_APP="mongodb"
TEMPLATE="jboss-eap64-openshift"
SRC="https://github.com/ffirg/openshift3mlbparks.git"
DEMO_USER="demo"
PROJECT="mlbparks"
build_status="NULL"

# include all our functions...
. ../libs/functions

# START
echo
echo "HOW TO WIRE UP A MULTI-TIERED OPENSHIFT v3 MICROSERVICE - MLBPARKS JBOSS/MONGO EXAMPLE"
echo

run_cmd echo "First login into OSE (as $DEMO_USER user)..."
run_cmd run "oc login -u $DEMO_USER"

# setup project
run_cmd echo "Setup the $PROJECT project"
run_cmd run "oc new-project $PROJECT --description \"MLBParks Demo App\""
run_cmd run "oc project $PROJECT"

# create the new front-end app
run_cmd echo "Create a new JBoss EAP front-end app..."
run_cmd run "oc new-app ${TEMPLATE}~${SRC}"

# wait until the build is finished before going on...
check_build ${FE_APP}

run_cmd echo "This is the front-end app build log..."
run_cmd run "oc logs builds/${FE_APP}-1"

run_cmd echo "Let's expose the service so it's accessible..."
run_cmd run "oc expose service openshift3mlbparks"

run_cmd echo "Go check the console and access the exposed service"

run_cmd echo "Now we need a back-end ${DB_APP} database to supply the MLBPARK data..."
run_cmd run "oc new-app ${DB_APP} -e MONGODB_USER=mlbparks -e MONGODB_PASSWORD=mlbparks -e MONGODB_DATABASE=mlbparks -e MONGODB_ADMIN_PASSWORD=mlbparks"

run_cmd echo "Now the clever bit... This will wire together the 2 micro-services..."
run_cmd run "oc env dc openshift3mlbparks -e MONGODB_USER=mlbparks -e MONGODB_PASSWORD=mlbparks -e MONGODB_DATABASE=mlbparks"

run_cmd echo "Go check the console and access the exposed service again"

#!/bin/bash

APP="mono"
SRC="https://github.com/ffirg/mono.git"
DEMO_USER="developer"
PROJECT="mono"
build_status="NULL"

# include all our functions...
. ../libs/functions

# START
echo
echo "HOW TO BUILD AN APP CONTAINER FROM SOURCE USING MONO AS AN EXAMPLE"
echo

run_cmd echo "First login into OSE (as $DEMO_USER user)..."
run_cmd run "oc login -u $DEMO_USER"

# setup project
run_cmd echo "Setup the $PROJECT project"
run_cmd run "oc new-project $PROJECT --description \"Mono Example App\""
run_cmd run "oc project $PROJECT"

# create the new app
run_cmd echo "Create a new Mono app from source..."
run_cmd run "oc new-app ${SRC}"

# wait until the build is finished before going on...
sleep 10 && check_build ${APP}

run_cmd echo "Let's expose the service so it's accessible..."
run_cmd run "oc expose service $APP"

run_cmd echo "Go check the console and access the app"

#!/usr/bin/bash

export BLUE_APP="blue"
export GREEN_APP="green"
DEMO_USER="demo"
PROJECT="bluegreen"
SRC="https://github.com/ffirg/bluegreen.git"
build_status="NULL"

# include all our functions...
. ../libs/functions

# START
echo
echo "EXAMPLE OPENSHIFT v3 APP BLUE/GREEN DEPLOYMENT"
echo "*** ENSURE color is set to $blue first in $SRC image.php ***"
echo

run_cmd echo "First login into OSE (as $DEMO_USER user)..."
run_cmd run "oc login -u $DEMO_USER"

# setup project
run_cmd echo "Setup the $PROJECT project"
run_cmd run "oc new-project $PROJECT --description \"BlueGreen Deployment\""
run_cmd run "oc project $PROJECT"

# do some dev work!
run_cmd echo "Create new app - call it the \"$BLUE_APP\" service"
run_cmd run "oc new-app $SRC --name=$BLUE_APP"

# wait until the build is finished before going on...
check_build $BLUE_APP

run_cmd echo "This is the build log..."
run_cmd run "oc build-logs ${BLUE_APP}-1"

run_cmd echo "Check out the service name:"
run_cmd run "oc get svc"

run_cmd echo "We have no route, so the service isn't exposed:"
run_cmd run "oc get route"

run_cmd echo "Let's expose it..."
run_cmd run "oc expose svc blue --name=bluegreen --hostname=bluegreen.example.com"

run_cmd echo "NOW CHANGE THE SOURCE CODE @ ${SRC} . Change image.php from BLUE to GREEN."

run_cmd echo "Create new app - call it the \"$GREEN_APP\" service"
run_cmd run "oc new-app $SRC --name=$GREEN_APP"

# wait until the build is finished before going on...
check_build $GREEN_APP

run_cmd echo "Check out the service names again:"
run_cmd run "oc get svc"

run_cmd echo "Now let's change the route to expose the new service:"
run_cmd run "oc edit route $PROJECT"

run_cmd echo "DANGER! DANGER! Code is broken, switch back quick!!!"
run_cmd run "oc edit route $PROJECT"

# THE END

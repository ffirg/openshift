#!/usr/bin/bash

export BLUE_APP="blue"
export GREEN_APP="green"
DEMO_USER="demo"
PROJECT="bluegreen"
SRC="https://github.com/ffirg/bluegreen.git"
build_status="NULL"

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
echo "EXAMPLE OPENSHIFT v3 APP BLUE/GREEN DEPLOYMENT"
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

run_cmd echo "NOW CHANGE THE SOURCE CODE FROM BLUE TO GREEN IMAGE..."

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

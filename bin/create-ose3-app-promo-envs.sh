#!/usr/bin/bash

export APP="myapp"
DEMO_USER="demo"
DEV_USER="dev1"
TEST_USER="test1"
DEV_ENV="development"
TEST_ENV="testing"
build_status="NULL"

. ../libs/functions

# START
echo
echo "WE'LL CREATE A DEV OPENSHIFT v3 APP + PROMOTE TO THE TEST (QA) ENV"
echo

# pre-reqs - local user accounts:
sudo useradd dev1 >/dev/null 2>&1
sudo passwd -f -u dev1 >/dev/null 2>&1
sudo useradd test1 >/dev/null 2>&1
sudo passwd -f -u test1 >/dev/null 2>&1


run_cmd echo "First login into OSE (as $DEMO_USER user)..."
run_cmd run "oc login -u $DEMO_USER"

# setup dev project and permissions
run_cmd echo "Setup the DEVELOPMENT Environment and permissions"
run_cmd run "oc new-project $DEV_ENV --description \"Development Env\""
run_cmd run "oc policy add-role-to-user edit dev1"
run_cmd run "oc policy add-role-to-user view test1"

# setup test/QA project and setup permissions
run_cmd echo "Now setup the TEST Environment and permissions"
run_cmd run "oc new-project $TEST_ENV --description=\"Test Env\""
run_cmd run "oc policy add-role-to-user edit test1"
run_cmd run "oc policy add-role-to-group system:image-puller system:serviceaccounts:testing -n development"

# do some dev work!
run_cmd echo "Do some DEV work!! Deploy the \"$APP\" application"
run_cmd run "oc login -u dev1 -p ''"
run_cmd run "oc get projects"
run_cmd run "oc project development"
# run_cmd run "oc new-app --template=eap64-basic-s2i https://github.com/VeerMuchandi/kitchensink.git name=$APP"
run_cmd run "oc new-app openshift/ruby-20-centos7~https://github.com/openshift/ruby-hello-world.git --name=$APP"

# force the build to start else there may be an variant timeout!
run_cmd echo "Start an image build for $APP"
run_cmd run "oc start-build $APP"
run_cmd echo "The build is now going - watch until it completes to ensure there's an image available..."
build_status="`oc get builds | grep ${APP}-1 | awk '{print $4}'`"
while true
do
  if [ -z $build_status ]
  then
    echo "Whoops! There is no build image, something went wrong :("
    exit 99
  else
    until [ $build_status = "Complete" ]
    do
      echo "$APP build is still $build_status..."
      sleep 10
      build_status="`oc get builds | grep ${APP}-1 | awk '{print $4}'`"
    done
  fi
  echo "$APP build is DONE!"
  echo
  break
done

run_cmd echo "This is the build log..."
run_cmd run "oc build-logs $APP-1"

run_cmd echo "Check out the image stream:"
run_cmd run "oc get is"
run_cmd run "oc describe is"

# *this is messy, really quick and dirty!*
image_ref="`oc get is $APP -o json | grep dockerImageReference | awk -F\\" '{print $4}'`"

run_cmd echo "We now tag the image with a \"promote\" label..."
oc tag $image_ref development/myapp:promote
run_cmd run "oc get is"
run_cmd run "oc describe is"

# now promote image into test env
run_cmd echo "Now login to the TEST Environment and 'promote' the application..."
run_cmd run "oc login -u test1 -p ''"
run_cmd run "oc project testing"
run_cmd run "oc new-app development/myapp:promote"

run_cmd echo "Let's check out what's been setup in $TEST_ENV..."
run_cmd run "oc get pods"
run_cmd run "oc get svc"
run_cmd run "oc get routes"
run_cmd echo "There is no external access so we setup a route to expose the service..."
run_cmd run "oc expose service myapp"
run_cmd run "oc get routes"

# make change to source code...
run_cmd echo "NOW SOMEONE MAKES CHANGES TO THE DEV CODE...TIME PASSES..."
#run_cmd run "oc login -u dev1 -p ''"
#run_cmd run "oc start-build myapp"
#run_cmd run "oc get builds"

# will now see that dev is on the 'latest' image but test remains on 'promote' version
run_cmd echo "The DEV environment will be on a new release, but TEST remains on the old one still"
#run_cmd run "oc describe is"
# change/fix/revert code as required and re-promote using 'oc tag' again
run_cmd echo "Use the same 'oc tag' command as before to promote the latest image into the TEST environment"
# THE END

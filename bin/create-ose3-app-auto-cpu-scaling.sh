#!/usr/bin/bash

export APP="welcome-php"
DEMO_USER="demo"
PROJECT="auto-cpu-scaling"
SRC="https://github.com/RedHatWorkshops/${APP}.git"
RESOURCE_LIMITS="../conf/resource-limits.yml"
SCALAR="../conf/scaler.yml"
TEMPLATE="openshift/php"
build_status="NULL"

# include all our functions...
. ../libs/functions

# START
echo
echo "EXAMPLE OPENSHIFT v3 HORIZONTAL AUTO CPU APP SCALING"
echo

run_cmd echo "First login into OSE (as $DEMO_USER user)..."
run_cmd run "oc login -u $DEMO_USER"

# setup project
run_cmd echo "Setup the $PROJECT project"
run_cmd run "oc new-project $PROJECT --description \"Example of Horizontal Auto CPU scaling\""
run_cmd run "oc project $PROJECT"

# need to setup resource limits on the project first...
run_cmd echo "Creating Resource Limits for this project..."
run_cmd run "sudo -s oc create -f ${RESOURCE_LIMITS} -n ${PROJECT}"

# Create the application...
run_cmd echo "Create a new application - ${APP}"
run_cmd run "oc new-app ${TEMPLATE}~${SRC}"

# wait until the build is finished before going on...
check_build ${APP}

run_cmd echo "Expose a route to the service..."
run_cmd run "oc expose svc ${APP}"

run_cmd echo "Setup the auto scaling metrics..."
run_cmd run "oc create -f ${SCALAR} -n ${PROJECT}"

# Initiate and wait for HPA setup to complete...
check_hpa

# Now let's generate some web load so we can test the metrics
# we'll use ab for that...
run_cmd echo "Now we'll generate some web traffic/load to test..."
run_cmd run "sudo yum -y install httpd-tools >/dev/null 2>&1"
run_cmd run "nohup ab -n 100000000 -c 75 http://${APP}-${PROJECT}.apps.example.com/ >/dev/null 2>&1 &"

# Now just watch until CPU load goes above target and back down again
run_cmd echo "Now let's watch the CPU load and see what happens in the GUI when load goes above target (more pods created)...ctrl-C to end..."
run_cmd run "oc get hpa --watch"

# THE END

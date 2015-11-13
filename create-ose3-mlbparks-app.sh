#!/usr/bin/bash

APP="mlbparks"

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

if [ ! $1 ]
then
  project=test
else
  project=$1
fi

# START
echo
echo "WE'LL CREATE A NEW OPENSHIFT v3 APP - MLBPARKS JBOSS/MONGO/GEOSPATIAL EXAMPLE (COOL)"
echo

echo "Have you logged into OSE as a project user?"
read x

run_cmd echo "CREATE NEW PROJECT CALLED $project"
run_cmd run "oc new-project $project --display-name=\"Testing Testing Testing\" --description=\"Demo OSE Apps\""
run_cmd run "oc project $project"

#run_cmd echo "ADD USER DEMO AS ADMIN"
#run_cmd run "oadm policy add-role-to-user admin demo $project"

run_cmd echo "CREATE/GET APP TEMPLATE..."
run_cmd run "oc create -f https://raw.githubusercontent.com/gshipley/openshift3mlbparks/master/mlbparks-template.json"
run_cmd echo "THE APPLICATION TEMPLATE IS NOW AVAILABLE IN THE PROJECT:"
run_cmd run "oc get template | grep $APP"

run_cmd echo "CREATE THE APPLICATION FROM THE TEMPLATE..."
run_cmd run "oc new-app $APP"

run_cmd echo "LET'S CHECK EVERYTHING..."

for i in services routes pods dc rc pods builds
do
  run_cmd echo "${i}:"
  run_cmd run "oc get $i | grep $APP"
done

#run_cmd echo "LET'S SCALE UP THE FRONT END SERVICE..."
#run_cmd run "oc scale --replicas=3 replicationcontrollers $APP-1"

#run_cmd echo "...AND SCALE BACK JUST FOR FUN..."
#run_cmd run "oc scale --replicas=1 replicationcontrollers $APP-mongodb-1"

#run_cmd echo "TO CLEAN UP AND DESTROY THE PROJECT, run 'oc delete project $project'"

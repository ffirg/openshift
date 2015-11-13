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
  project=openshift-demo2
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
#cd ~/origin/examples/sample-app
#./pullimages.sh

run_cmd echo "CREATE NEW PROJECT CALLED $project"
run_cmd run "oc new-project $project --display-name=\"Openshift3 Demo 2\" --description=\"Demos of PHP and NodeJS Multi-tier\""

run_cmd echo "ADD USER PHIL AS ADMIN"
run_cmd run "oadm policy add-role-to-user admin phil $project"

run_cmd echo "CREATE NEW APP FROM GITHUB SOURCE PULL"
run_cmd run "oc new-app openshift/php~https://github.com/christianh814/php-example-ose3"

run_cmd echo "CREATE ROUTE TO EXPOSE THE APPS"
run_cmd run "oc expose service php-example-ose3 --hostname=php-example.cloudapps.example.com"

run_cmd echo "ADD A SERVICE ALIAS AS WELL"
run_cmd run "oc expose service php-example-ose3 --name=hello-openshift --hostname=hello-openshift.cloudapps.example.com"

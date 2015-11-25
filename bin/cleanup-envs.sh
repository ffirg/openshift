#!/bin/bash

PROJECT="_null_"
PROJECTS="testing development test bluegreen abdeployment mlbparks"
DEMO_USER="demo"

. ../libs/functions

# HOW TO USE THIS SCRIPT...
usage() {
  echo "${0} -p [ project_name | all ]"
  exit
}

# parse arguments
while getopts ":p:" opt
do
  case ${opt} in
    p)
      if [ "${OPTARG}" = "all" ]
      then
        PROJECT=$PROJECTS
      else
        PROJECT="${OPTARG}"
      fi
      ;;
    \?)
      echo "Invalid option: -${OPTARG}" 
      usage
      exit 1
      ;;
    :)
     echo "Option -${OPTARG} requires an argument"
     usage
     exit 1
     ;;
  esac
done

# bail out if we don't have the right arguments
if [ "${PROJECT}" = "_null_" ]
then
  usage
fi

# START
echo
echo "REMOVE DEMO APPS..."
echo

echo "Logging in as ${DEMO_USER} user..."
oc login -u ${DEMO_USER}

for p in ${PROJECT}
do
  echo "Deleting project \"${p}\"..."
  oc delete project ${p} 2>/dev/null
done


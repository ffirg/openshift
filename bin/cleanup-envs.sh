#!/bin/bash

PROJECT="_null_"
PROJECTS="`oc get projects -o name | sed -e 's/project\///'`"
DEMO_USER="developer"

. ../libs/functions

# HOW TO USE THIS SCRIPT...
usage() {
  echo "${0} -p [ project_name | all ]"
  exit
}

# No point doing anything if we don't have any projects!
if [ `echo ${PROJECTS} | wc -w` -eq 0 ]
then
  echo "No projects to delete here!"
  exit
fi

#echo "Existing projects:"
#echo "${PROJECTS}"

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

# ask for project if none passed as args and we have something to delete!
if [ "${PROJECT}" = "_null_" ]
then
  echo "Choose project to delete:"
  select PROJECT in ${PROJECTS}
  do
    break
  done
fi

# START
echo
echo "REMOVE PROJECT(S)..."
echo

# Need to login into demo namespace...
echo "Logging in as ${DEMO_USER} user..."
oc login -u ${DEMO_USER}

# Finally, do the dirty work
if [ "${PROJECT}" != "_null_" -a "${PROJECT}" != "" ]
then
  for p in ${PROJECT}
  do
    echo "Deleting project \"${p}\"..."
    oc delete project ${p} 2>/dev/null
  done
else
  exit
fi

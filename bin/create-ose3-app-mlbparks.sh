#!/usr/bin/env bash

RED='\033[0;31m'
NC='\033[0m' # No Color

APP="mlbparks-wildfly"
TEMPLATE="https://raw.githubusercontent.com/gshipley/openshift3mlbparks/master/mlbparks-template-wildfly.json"
USER="developer"
PROJECT="mlbparks"
build_status="NULL"

# include all our functions...
. ../libs/functions

# START
echo
echo "HOW TO WIRE UP A MULTI-TIERED OPENSHIFT v3 MICROSERVICE - MLBPARKS JBOSS/MONGO EXAMPLE"
echo

run_cmd echo "${RED}First login into OSE (as $USER user)...${NC}"
run_cmd run "oc login -u $USER"

# setup project
run_cmd echo "${RED}Create the $PROJECT project${NC}"
run_cmd run "oc new-project $PROJECT --description \"MLBParks Demo App\""
run_cmd run "oc project $PROJECT"

# create the new front-end app
run_cmd echo "${RED}Create a new ${APP} template...${NC}"
run_cmd run "oc create -f ${TEMPLATE}"

run_cmd echo "${RED}Create a new ${APP} app...${NC}"
run_cmd run "oc new-app ${APP}"

run_cmd echo "${RED}Go to openshift console and review builds etc...${NC}"

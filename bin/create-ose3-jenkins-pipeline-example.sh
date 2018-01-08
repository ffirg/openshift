#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
export EDITOR=vim # needed on Mac for a workaround to using vi!
export APP="jenkins"
USER="developer"
PROJECT="pipeline-example"
build_status="NULL"

# include all our functions...
. ../libs/functions

# START
echo
echo "EXAMPLE OPENSHIFT v3 JENKINS PIPELINE-AS-CODE EXAMPLE"
echo -e "*** ENSURE color is set to ${BLUE}${BLUE_APP}${NC} first in $SRC image.php ***"
echo

run_cmd echo -e "${RED}First login into OSE (as $USER user)...${NC}"
run_cmd run "oc login -u $USER"

# setup project
run_cmd echo -e "${RED}Create the $PROJECT project${NC}"
run_cmd run "oc new-project $PROJECT --description \"Jenkins Pipeline-As-Code Example\""
run_cmd run "oc project $PROJECT"

# do some dev work!
run_cmd echo -e "${RED}Create new app..."
run_cmd run "oc new-app jenkins-pipeline-example"

# start a pipeline build/deploy
run_cmd echo -e "${RED}Start Pipeline build/deployment..."
run_cmd run "oc start-build sample-pipeline"

# THE END

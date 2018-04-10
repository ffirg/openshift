#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
export EDITOR=vim # needed on Mac for a workaround to using vi!

export BLUE_APP="blue"
export GREEN_APP="green"
USER="developer"
PROJECT="bluegreen"
SRC="https://github.com/ffirg/bluegreen.git"
build_status="NULL"

# include all our functions...
. ../libs/functions

# START
echo
echo "EXAMPLE OPENSHIFT v3 APP BLUE/GREEN DEPLOYMENT"
echo -e "*** ENSURE color is set to ${BLUE}${BLUE_APP}${NC} first in $SRC image.php ***"
echo

run_cmd echo -e "${RED}First login into OSE (as $USER user)...${NC}"
run_cmd run "oc login -u $USER"

# setup project
run_cmd echo -e "${RED}Create the $PROJECT project${NC}"
run_cmd run "oc new-project $PROJECT --description \"BlueGreen Deployment\""
run_cmd run "oc project $PROJECT"

# do some dev work!
run_cmd echo -e "${RED}Create new app - call it the \"$BLUE_APP\" service${NC}"
run_cmd run "oc new-app $SRC --name=$BLUE_APP"

# wait until the build is finished before going on...
check_build $BLUE_APP

run_cmd echo -e "${RED}Let's take a look at the build log...${NC}"
run_cmd run "oc logs build/${BLUE_APP}-1"

run_cmd echo -e "${RED}Check out the service name:${NC}"
run_cmd run "oc get svc"

run_cmd echo -e "${RED}We have no route, so the service isn't exposed:${NC}"
run_cmd run "oc get route"

run_cmd echo -e "${RED}Let's expose the service now...${NC}"
#run_cmd run "oc expose svc blue --name=bluegreen --hostname=bluegreen.192.168.99.100.xip.io"
run_cmd run "oc expose svc blue --name=bluegreen"

run_cmd echo "NOW CHANGE THE SOURCE CODE @ ${SRC} . Change image.php from ${BLUE}${BLUE_APP}${NC} to ${GREEN}${GREEN_APP}${NC}."

run_cmd echo -e "${RED}Create new app - call it the \"$GREEN_APP\" service${NC}"
run_cmd run "oc new-app $SRC --name=$GREEN_APP"

# wait until the build is finished before going on...
check_build $GREEN_APP

run_cmd echo -e "${RED}Check out the service names again:${NC}"
run_cmd run "oc get svc"

run_cmd echo -e "${RED}Now let's change the route to expose the new service:${NC}"
run_cmd echo "You can edit the route directly using: oc edit route $PROJECT"
run_cmd echo "Or even directly with oc patch"
run_cmd echo "But we'll do this using good old sed :)"
run_cmd run "oc get route/bluegreen -o yaml | sed -e 's/name: blue$/name: green/' | oc replace -f -"
# can also now use 'oc patch' directly
# oc patch route/bluegreen -p '{"spec":{"to":{"name":"blue"}}}'

run_cmd echo -e "${RED}DANGER! DANGER! Code is broken, switch back quick!!!${NC}"
run_cmd run "oc get route/bluegreen -o yaml | sed -e 's/name: green$/name: blue/' | oc replace -f -"

# THE END

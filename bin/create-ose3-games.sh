#!/bin/bash

APP=""
SRC=""
DEMO_USER="developer"
PROJECT="games"
IMAGE="centos/httpd-24-centos7"
build_status="NULL"

# include all our functions...
. ../libs/functions

# START
echo
echo "EXAMPLE HTML5 GAMES RUN ON OPENSHIFT"
echo

run_cmd echo "First login into OSE (as $DEMO_USER user)..."
run_cmd run "oc login -u $DEMO_USER"

# setup project
run_cmd echo "Setup the $PROJECT project"
run_cmd run "oc new-project $PROJECT --description \"HTML5 Based Games\""
run_cmd run "oc project $PROJECT"

# choose a game!
echo "Which game would you like?"
echo ""
echo "1 Flappy Birds"
echo "2 Arena5"
echo "3 Pixel Race"
echo "4 2048"
echo "5 Pacman"
echo "6 Hextris"
echo "7 Pool"
echo "8 Battleships (2 Player)"
echo ""
read ans

case "$ans" in
  1 ) 
    export APP="flappy"
    export SRC="https://github.com/hyspace/flappy"
    ;;
  2 )
    export APP="arena5"
    export SRC="https://github.com/kevinroast/arena5"
    ;;
  3 )
    export APP="pixel-race"
    export SRC="https://github.com/needim/pixel-race-game"
    ;;
  4 )
    export APP="game-2048"
    export SRC="https://github.com/gabrielecirulli/2048"
    ;;
  5 )
    export APP="pacman"
    export SRC="https://github.com/daleharvey/pacman"
    ;;
  6 )
    export APP="hextris"
    export SRC="https://github.com/Hextris/hextris"
    ;;
  7 )
    export APP="pool"
    export SRC="https://github.com/henshmi/Classic-Pool-Game"
    ;;
  8 )
    export APP="battleships"
    export SRC="https://github.com/nixsolutions/demo-phaser-battleship"
    ;;
esac

run_cmd run "oc new-app ${IMAGE}~${SRC} --name=\"${APP}\""

# wait until the build is finished before going on...
sleep 10 && check_build ${APP}

run_cmd echo "Let's expose the service so it's accessible..."
run_cmd run "oc expose service $APP"

run_cmd echo "Go check the console and access the app"

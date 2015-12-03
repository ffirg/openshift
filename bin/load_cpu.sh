#!/usr/bin/bash

#
# load_cpu.sh: artificial CPU load generator
#

# Usage: lc [number_of_cpus_to_load [number_of_seconds] ]

lc() {
  (
    pids=""
    cpus=${1:-1}
    seconds=${2:-60}
    echo loading $cpus CPUs for $seconds seconds
    trap 'for p in $pids; do kill $p; done' 0
    for ((i=0;i<cpus;i++)); do while : ; do : ; done & pids="$pids $!"; done
    sleep $seconds
  )
}

lc $*

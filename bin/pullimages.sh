#!/bin/sh
docker pull openshift/origin-docker-registry
#docker pull openshift/origin-docker-builder
docker pull openshift/origin-sti-builder
docker pull openshift/origin-deployer
docker pull docker.io/openshift/ruby-20-centos7

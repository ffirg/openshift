# Openshift
Scripts in here are used to perform the demo functions
They include scripts for creating apps, deleting projects and adding resources, quotas etc

```
add-resouce-quota.sh
```
Assigns sample quota limits to a project. Needs to be run as root.

```
cleanup-envs.sh
```
Deletes namespace projects

```
create-ose3-app-mlbparks.sh
```
Creates the JBoss EAP and MongoDB MLBParks demo app.

```
create-ose3-app-ab-deployment.sh
```
Creates the A-B Rolling Deployment app scenario.

```
create-ose3-app-bluegreen-deployment.sh
```
Creates the Blue-Green Deployment app scenario.

```
create-ose3-app-promo-envs.sh
```
Creates an Application Promotion style scenario.

```
create-ose3-app-auto-cpu-scaling.sh
```
Setup and demonstrate CPU load for showcasing resource/scaling controls.

```
create-ose3-app-from-source-mono.sh
```
Create and run an application from just a source Dockerfile, using Mono as the example.

```
pullimages.sh
```
Pre-populate some of the more common images used so they are in the local registry.

```
setup-cluster-metrics.sh
```
Use to create the initial setup required for Cluster Metrics (EFK), for auto horizontal CPU pod scaling.
```
setup-efk-logging.sh
```
Use to create the initial setup required for EFK, hawkular, heapster and cassandra centralised logging.


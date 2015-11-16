# openshift
Scripts for stepping through OSE demo examples

### Setup
Using demobuilder all-in-one image as your base, open up the console and fire up the Firefox browser and a Terminal.

### What They Demo

```
$ create-ose3-mlbparks-app.sh
```

Created the visually appealing MLBParks example. Overlays baseball venues on to Google Maps.
MongoDB is used for the back-end database, so this demonstrates a multi-tiered application.

```
create-ose3-app-promo-envs.sh
```
Demonstrates how an application can be 'promoted' from one environment to another. The example uses Development & Test/QA, to show how an application can be released in a manual and controlled manner.

```

```

### Running
In the Terminal (as the demo user):
```
$ cd /home/demo
$ git clone https://github.com/ffirg/openshift.git
$ cd openshift
$./create-ose3-mlbparks-app.sh or other script
```
Follow the prompts!

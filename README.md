# Openshift
Scripts for stepping through OSE demo examples, showcasing various applications and scenarios.
Based on the most excellent working demos done by Veer -> https://github.com/VeerMuchandi

### Setup
Using demobuilder all-in-one image as your base, open up the console and fire up the Firefox browser and a Terminal.

### What They Demo

```
$ create-ose3-mlbparks-app.sh
```

Creates the visually appealing MLBParks example. Overlays baseball venues on to Google Maps.
MongoDB is used for the back-end database, so this demonstrates a multi-tiered application.

```
$ create-ose3-app-promo-envs.sh
```

Demonstrates how an application can be 'promoted' from one environment to another. The example uses Development & Test/QA, to show how an application can be released in a manual and controlled manner.  See https://www.youtube.com/watch?v=Rzsa6VJRGDw for a demo. 

```
$ create-ose3-app-bluegreen-deployment.sh
```

Shows how you can deploy 2 versions of the same application, and 'flick' the exposed route between them to allow one service or the other to be used. This example could be used in environments where there is still fairly rigid change control, who like a more 'big bang' release approach still. Could also be used for DR testing for the application on a regular basis! See https://www.youtube.com/watch?v=Rzsa6VJRGDw for a demo. 

```
$ create-ose3-app-ab-deployment.sh
```

Shows how to do rolling A-B or Canary style deployments. Bring application version one into service. Then change the code to make version 2 and deploy that into the service but in incremental stages. Turn off version 1, once everyones happy with version 2. Enables a lower risk application deployment strategy, with rollback capabilities.

### Running
In the Terminal (as the demo user):
```
$ cd /home/demo
$ git clone https://github.com/ffirg/openshift.git
$ cd openshift
$./create-ose3-mlbparks-app.sh
```
Follow the prompts!

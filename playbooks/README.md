# Ansible Playbooks For Demo Scripts
You can use these to auto deploy the walkthrough demo scripts, used in conjunction with demobuilder.

### Setup

You have a demobuilder all-in-one master/node VM up and running.
You might need to change the entries in the ansible_hosts file if you've different OSE hostnames

You already have a local ansible client installed and SSH keys setup as per the normal ansible installation/setup guides.

### Installing

To install the demo scripts from a client CLI:

```
$ cd playbooks
$ ansible-playbook -i ./ansible_hosts ./ose3-master-scripts.yml
```

### Vagrant auto provisioning


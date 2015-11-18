# Ansible Playbooks For Demo Scripts
You can use these to auto deploy the walkthrough demo scripts, used in conjunction with demobuilder.

### Setup

You have a demobuilder all-in-one master/node VM, or vagrant config to bring it up.

You might need to change the entries in the ansible_hosts file if you've different OSE hostnames

You already have a local ansible client installed and SSH keys setup as per the normal ansible installation/setup guides.

### Installing

To install the demo scripts from a client CLI:

```
$ cd ~/openshift/playbooks
$ ansible-playbook -i ./ansible_hosts ./ose3-master-scripts.yml
```

### Vagrant Auto Provisioning

You can get vagrant to auto provision as part of the initialisation. *This isn't working currently - looks like an issue with SSH keys, so use this as a reference only*

Add this to your Vagrantfile:

```
# If you want to do some ansible provisioning, this is how...
  config.vm.provision "ansible" do |ansible|
    #ansible.limit = 'ose-offline-demo'
    #ansible.inventory_path = "ansible/ansible_hosts"
    ansible.playbook = "ansible/ose3-master-scripts.yml"
  end
```

When you run ```vagrant up``` it'll call the provisioning plugin to deploy.
If your VM is already up, then use ```vagrant provision```

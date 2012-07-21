# bosh-solo

Develop, test and deploy BOSH releases without BOSH. It makes developing BOSH releases suck a lot less.

BOSH releases describe a complete running system from the ground up - compiled packages from source, templated configuration files, and monit to start/stop processes. BOSH itself then allows you to deploy your release across 1 or more VMs with optional persistent disks on the target infrastructure of your choice.

This is a tool to iteratively develop and test a BOSH release in a local or remote VM, without needing to use a running BOSH system.

## Installation

The project is installed and operated by the [SM framework](https://github.com/sm/sm). Installation instructions for SM, git

Install SM and git:

```
apt-get install git-core curl -y
curl -L https://get.smf.sh | sh
source /etc/profile.d/sm.sh
```

Install bosh-solo and prepare the target machine/VM for deploying a BOSH release:

```
sm ext install bosh-solo git://github.com/drnic/bosh-solo.git
sm bosh-solo install_dependencies
```

### Updating bosh-solo

```
sm ext update bosh-solo
```

### Other commands

To discover the complete list of available commands, either read the scripts in [bosh-solo bin/](https://github.com/drnic/bosh-solo/tree/master/bin) folder, or run:

```
sm bosh-solo
```

## Usage

The are two modes to use: a local Vagrant VM or a remote VM.

### Vagrant usage

[Install SM framework](https://github.com/sm/sm#installation) and bosh-solo into your local machine. Do not run `install_dependencies` as this is a script for the target Vagrant VM, not your laptop.

```
[inside local machine]
curl -L https://get.smf.sh | sh
source /etc/profile.d/sm.sh
sm ext install bosh-solo git://github.com/drnic/bosh-solo.git
```

Create a `Vagrantfile` into your BOSH release and launch Vagrant. If you haven't used Vagrant to download the `lucid64` box before it will be automatically downloaded.

```
sm bosh-solo local vagrantfile
gem install vagrant
vagrant up
vagrant ssh
```

Inside your Vagrant VM you now install SM, the bosh-solo extension, and prepare the VM with dependencies:


```
[inside vagrant as vagrant user]
sudo su -

[inside vagrant as root user]
apt-get install curl git-core -y

curl -L https://get.smf.sh | sh
source /etc/profile.d/sm.sh
sm ext install bosh-solo git://github.com/drnic/bosh-solo.git
sm bosh-solo install_dependencies
source /etc/profile.d/rvm.sh
rvm 1.9.3 --default
```

You are now ready to install & deploy your bosh release over and over again.

Each time you want to deploy a change to your BOSH release into your Vagrant VM:

```
[within your local machine in BOSH release folder]
bosh create release --force

[inside vagrant as root user]
cd /vagrant/
sm bosh-solo update examples/example.yml
```

The generated Vagrantfile forwards the internal port `:80` to your local machine's port `:5001`. That is [http://localhost:5001](http://localhost:5001) in your browser will go to `localhost:80` within your Vagrant VM.

### Remote VM usage

Clone your BOSH release into your remote VM. Create a dev release (which will also sync download any blobs that are required), and run the bosh-solo `update` command.

```
git clone git://location.com/your/bosh_release.git
cd bosh_release
bosh create release
sm bosh-solo update path/to/manifest.yml
```

Whenever you update your BOSH release repository, you can fetch the changes and update your remote VM with the new packages and jobs:

```
git pull origin master
bosh create release --force
sm bosh-solo update path/to/manifest.yml
```


## Full tutorials

### Full tutorial on local Vagrant VM

Commands below are run either within your local machine (laptop) or within a Vagrant VM that will be provisioned:

Fetch the example BOSH release and create a release:

```
[inside local machine]
git clone git://github.com/drnic/bosh-sample-release.git -b examples
cd bosh-sample-release
gem install bosh_cli
bosh create release
```

Now install bosh-solo via SM framework:

```
[inside local machine]
curl -L https://get.smf.sh | sh
source /etc/profile.d/sm.sh
sm ext install bosh-solo git://github.com/drnic/bosh-solo.git
```

Now create a Vagrant file and launch Vagrant VM:

```
[inside local machine]
sm bosh-solo local vagrantfile
gem install vagrant
vagrant up
vagrant ssh
```

You are now inside the Vagrant VM. Install bosh-solo within the VM. Also install the dependencies required for deploying BOSH releases via bosh-solo.

```
[inside vagrant as vagrant user]
sudo su -

[inside vagrant as root user]
curl -L https://get.smf.sh | sh
source /etc/profile.d/sm.sh
sm ext install bosh-solo git://github.com/drnic/bosh-solo.git
sm bosh-solo install_dependencies

source /etc/profile.d/rvm.sh
rvm 1.9.3 --default
```

Now go to `/vagrant` directory where your bosh release is shared within the VM:

```
[inside vagrant as root user]
cd /vagrant
sm bosh-solo update examples/solo.yml
```

### Full tutorial on remote VM

All commands are run within your remove, Ubuntu 64-bit VM:

```
git clone git://github.com/drnic/bosh-sample-release.git -b examples
cd bosh-sample-release
sm bosh-solo update examples/solo.yml
```

The complete, end-to-end tutorial is therefore:

```
sudo su -
curl -L https://get.smf.sh | sh
source /etc/profile.d/sm.sh
apt-get install git-core -y

sm ext install bosh-solo git://github.com/drnic/bosh-solo.git
sm bosh-solo install_dependencies

git clone git://github.com/drnic/bosh-sample-release.git -b examples
cd bosh-sample-release
bosh create release
sm bosh-solo update examples/solo.yml
```

## Development

This section described the processes and rules for developing on bosh-solo itself.

The HEAD of the master branch is the currently released version of bosh-solo, due to the installation method with SM framework.

Therefore, all development and testing should be done in branches.

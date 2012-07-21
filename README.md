# bosh-solo

Develop, test and deploy BOSH releases without BOSH

This is a tool to iteratively develop and test a BOSH release in a local or remote VM, without needing to use a running BOSH system.

## Installation

The project is installed and operated by the [SM framework](https://github.com/sm/sm). Installation instructions for SM, git

Install SM and git:

```
curl -L https://get.smf.sh | sh
source /etc/profile.d/sm.sh
apt-get install git-core -y
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

## Usage

The are two modes to use: a local Vagrant VM or a remote VM.

### Vagrant usage

[Install SM framework](https://github.com/sm/sm#installation) and bosh-solo into your local machine. Do not run `install_dependencies` as this is a script for the target Vagrant VM, not your laptop.

```
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


### Example usage

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
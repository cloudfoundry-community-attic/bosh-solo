# bosh-solo

Develop, test and deploy BOSH releases without BOSH. Develop an entire working system quickly before you deploy to production.

BOSH releases describe a complete running system from the ground up - compiled packages from source, templated configuration files, and monit to start/stop processes. BOSH itself then allows you to deploy your release across 1 or more VMs with optional persistent disks on the target infrastructure of your choice.

Compilation of packages is only performed once. Compilation errors of packages and template rendering errors in jobs do not affect the running system.

This is a tool to iteratively develop and test a BOSH release in a local or remote VM, without needing to use a running BOSH system.

## Overview

This is a tool to use during development of your BOSH releases. Each time you make a change to a package (sources or packaging) or jobs (templates or scripts), you can apply the updates to a virtual machine (local Vagrant or remote).

When applying each BOSH release into a VM you can specify which jobs to run (runs all by default) and what custom properties (aka databags or attributes) are to be applied to the templates. This way you can both document different use cases of your BOSH release and test that the examples work as expected.

```
[within the VM as root]
sm bosh-solo update path/to/manifest.yml
```

It may be a good idea to include example manifests within an `examples/` folder. For a two-tiered web application, possible manifests might be `examples/with_database.yml` with `examples/without_database.yml`. The latter might look like:

``` yaml
---
jobs:
  - webapp
  - postgres
properties:
  webapp:
    use_nginx: 1
    run_migrations: 1
    appstack: puma
  postgres:
    host: 127.0.0.1
    user: todo
    password: p03tgR3s
    database: todo
```

You could also use a testing tool such as [roundup](http://bmizerany.github.com/roundup/ "roundup"), [minitest](https://github.com/seattlerb/minitest) or [rspec](http://rspec.info/ "RSpec.info: home") to do local integration tests. Within each group of tests, apply the current BOSH release with an example manifest and assert that specific processes and outcomes are observed.

Example manifests assume that there is only one VM. For example, the `properties.postgres.host` is set to `127.0.0.1`. When the BOSH release is deployed into production it would be a real IP or DNS.

Allowing you to iterate on BOSH releases within a local VM means you can quickly see any errors during package compilation or the running of jobs via monit. All log files within `/var/vcap/sys/log` can be displayed or tailed using one of the following examples:

```
sm bosh-solo tail_logs -n 200 # for each log file show last 200 lines
sm bosh-solo tail_logs -f     # for each log file, tail any new output
sm bosh-solo tail_error_logs  # as above, only for err/error log files
```

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
git clone git://github.com/drnic/bosh-sample-release.git -b merge
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
apt-get install curl git-core -y

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

All commands are run within your remove, Ubuntu 64-bit VM. 

NOTE: Remember to attach a large enough root volume for your release (or attach it at `/var/vcap`). For example, the [oss-release](https://github.com/cloudfoundry/oss-release) (jenkins/gerrit) is too big to build against the default size 8G root volume created by fog.


```
git clone git://github.com/drnic/bosh-sample-release.git -b merge
cd bosh-sample-release
sm bosh-solo update examples/solo.yml
```

The complete, end-to-end tutorial is therefore:

```
sudo su -

apt-get install curl git-core -y

curl -L https://get.smf.sh | sh
source /etc/profile.d/sm.sh

sm ext install bosh-solo git://github.com/drnic/bosh-solo.git
sm bosh-solo install_dependencies

source /etc/profile.d/rvm.sh
rvm 1.9.3 --default

git clone git://github.com/drnic/bosh-sample-release.git -b merge
cd bosh-sample-release
bosh create release
sm bosh-solo update examples/solo.yml
```

## Development

This section described the processes and rules for developing on bosh-solo itself.

The HEAD of the master branch is the currently released version of bosh-solo, due to the installation method with SM framework.

Therefore, all development and testing should be done in branches.

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
6. Send extra spicy Doritos to Dr Nic

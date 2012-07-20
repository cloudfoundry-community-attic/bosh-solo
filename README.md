# bosh-solo

This is a tool to iteratively develop and test a BOSH release in a local or remote VM, without needing to use a running BOSH system.

## Installation via SM framework

As root user, to install the SM framework, this project as an SM extension, and prepare the target machine/VM for using `bosh-solo` run:

```
curl -L https://raw.github.com/sm/sm/master/bin/sm-installer | sh
source /etc/profile.d/sm.sh
sm ext install bosh-solo git://github.com/drnic/bosh-solo.git
sm bosh-solo install_dependencies
```

## Usage

```
cd path/to/bosh_release
sm bosh-solo update path/to/manifest.yml
```

### Example usage

TODO: Make the following example BOSH release

```
git clone git://github.com/drnic/bosh-sample-release.git
cd rackapp-boshrelease
sm bosh-solo update examples/solo.yml
```

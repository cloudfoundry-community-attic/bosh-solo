# bosh-solo

This is a tool to iteratively develop and test a BOSH release in a local or remote VM, without needing to use a running BOSH system.

## Installation via SM framework

```
curl -L https://raw.github.com/sm/sm/master/bin/sm-installer | sh
source /etc/profile.d/sm.sh
sm ext install bosh-solo git://github.com/drnic/bosh-solo.git
```
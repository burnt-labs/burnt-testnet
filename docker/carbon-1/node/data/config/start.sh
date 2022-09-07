#!/usr/bin/env bash
set -eux

BASEDIR=/home/burntd/.burnt

if [ ! -f $BASEDIR/init.semaphore ]
then
  # perform initial config on first-time boot
  burntd init node.burnt.com --chain-id carbon-1 --home $BASEDIR
  wget -O $BASEDIR/config/genesis.json https://burnt-use1testnet-carbon-1.s3.amazonaws.com/genesis.json
  cp -vf /tmp/node/config/*.toml $BASEDIR/config/
  touch $BASEDIR/init.semaphore
fi

burntd start --x-crisis-skip-assert-invariants --home $BASEDIR

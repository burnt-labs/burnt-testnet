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

rm -vf $BASEDIR/config/*.toml
rm -vf $BASEDIR/config/node_key.json
rm -vf $BASEDIR/config/priv_validator_key.json

ln -s /tmp/configmaps/app.toml $BASEDIR/config/app.toml
ln -s /tmp/configmaps/client.toml $BASEDIR/config/client.toml
ln -s /tmp/configmaps/config.toml $BASEDIR/config/config.toml
ln -s /tmp/node-keys/node_key.json $BASEDIR/config/node_key.json
ln -s /tmp/node-keys/priv_validator_key.json $BASEDIR/config/priv_validator_key.json

burntd start --x-crisis-skip-assert-invariants --home $BASEDIR

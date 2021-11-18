#!/bin/bash

set -e

cd ~/

if ! test -d ~/mailinabox
then
  git clone https://github.com/mail-in-a-box/mailinabox  ~/mailinabox
fi

cd ./mailinabox

git checkout v0.55

sudo ./setup/start.sh

cd ~/

#!/bin/bash

set -e

git clone https://github.com/mail-in-a-box/mailinabox

cd ./mailinabox

git checkout v0.53a

sudo ./setup/start.sh

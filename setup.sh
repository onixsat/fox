#!/usr/bin/env bash
set -euo pipefail

sudo apt update -y
sudo apt install -y git nano wget dos2unix php8.3-cli

git clone https://github.com/onixsat/fox.git
dos2unix fox/*
find -name '*.sh' -print0 | xargs -0 dos2unix

cd fox
bash btk.sh

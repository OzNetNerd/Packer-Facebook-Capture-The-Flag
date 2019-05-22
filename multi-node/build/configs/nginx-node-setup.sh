#!/bin/bash -e
git clone https://github.com/facebook/fbctf
cd fbctf
source ./extra/lib.sh
quick_setup install_multi_nginx prod 10.0.0.101
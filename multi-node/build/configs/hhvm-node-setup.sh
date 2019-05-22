#!/bin/bash -e
git clone https://github.com/facebook/fbctf
cd fbctf
source ./extra/lib.sh
quick_setup install_multi_hhvm prod 10.0.0.103 10.0.0.102
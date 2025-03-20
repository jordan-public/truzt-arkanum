#!/bin/zsh
set -e
set -x

# Run ./run_node.sh to start the node before running this script

cd token_registry_workaround
./install.sh
cd ../bean_token
./install.sh
cd ..
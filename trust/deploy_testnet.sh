#!/bin/zsh
set -e
set -x

. ./.env

leo deploy --path . --network testnet --private-key $TESTNET_PRIVATE_KEY --endpoint $TESTNET_ENDPOINT --yes --recursive

#!/bin/zsh
set -e

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <wrapper_token_id> <amount>u128 <destination> <nonce>u64"
    exit 1
fi

leo run transfer $1 $2 $3 $4
leo execute transfer $1 $2 $3 $4 --broadcast --yes --local

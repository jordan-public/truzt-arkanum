#!/bin/bash
set -e

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <token_id> <spender> <amount>u128"
    exit 1
fi

leo execute approve_public $1 $2 $3 --broadcast --yes --local
#!/bin/zsh
set -e
set -x

if [ $# -ne 2 ]; then
    echo "Usage: $0 <address> <amount>u128"
    exit 1
fi

leo execute mint_public $1 $2 --broadcast --yes --local

#!/bin/zsh
set -e

. ./.env

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <will_record> <decoy_time>u32"
    exit 1
fi

leo run cash_out $1 $2
leo execute cash_out $1 $2 --broadcast --yes --local

#!/bin/zsh
set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <nonce>u64"
    exit 1
fi

leo run generate_dead_address $1

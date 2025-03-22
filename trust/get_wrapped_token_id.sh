#!/bin/zsh
set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <token_id>"
    exit 1
fi

leo run get_wrapped_id $1

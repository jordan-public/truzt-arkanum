#!/bin/zsh
set -e

. ./.env

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <will_record>, <trustee>"
    exit 1
fi

leo run add_trustee $1 $2
leo execute add_trustee $1 $2 --broadcast --yes --local

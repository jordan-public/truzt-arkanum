#!/bin/zsh
set -e

. ./.env

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <will_record>, <trustee_consent_record>"
    exit 1
fi

leo run register_approval $1 $2
leo execute register_approval $1 $2 --broadcast --yes --local

#!/bin/zsh
set -e

. ./.env

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <trustee_consent_record>"
    exit 1
fi

leo run trustee_consents $1
leo execute trustee_consents $1 --broadcast --yes --local

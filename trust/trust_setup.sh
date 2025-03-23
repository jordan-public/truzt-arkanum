#!/bin/zsh
set -e

. ./.env

if [ "$#" -ne 6 ]; then
    echo "Usage: $0 <funding_record> <beneficiary> <will_id> <approvals_needed> <good_after>"
    exit 1
fi

# snarkos developer execute --query $ENDPOINT trust.aleo trust_setup $1 $2 $3 $4 %5 --private-key $PRIVATE_KEY --network 1

leo run trust_setup $1 $2 $3 $4 $5 $6
# leo execute trust_setup $1 $2 $3 $4 $5 $6--broadcast --yes --local

#!/bin/zsh
set -e

VERIFY_BALANCE=false

while getopts "v" opt; do
    case $opt in
        v) VERIFY_BALANCE=true ;;
        *) ;;
    esac
done
shift $((OPTIND-1))

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 [-v] <token_id> <amount>u128"
    echo "  -v: Verify balance after wrapping"
    exit 1
fi

leo execute wrap_public $1 $2 --broadcast --yes --local

if [ "$VERIFY_BALANCE" = true ]; then
    pushd ../cli
    ./bal.js . $1
    echo "This is the balance if unwrapped token"
    popd
fi

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

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 [-v] <amount>u128"
    echo "  -v: Verify balance after wrapping"
    exit 1
fi

leo execute wrap_public 1986245370112742436875568105128650176313749927841508924213988105972156054969field $1 --broadcast --yes --local

if [ "$VERIFY_BALANCE" = true ]; then
    pushd ../cli
    ./bal.js . WBEAN
    echo "This is the balance if unwrapped token"
    popd
fi

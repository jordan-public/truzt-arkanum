#!/bin/bash
set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <spender> <amount>u128"
    exit 1
fi

./approve.sh 1986245370112742436875568105128650176313749927841508924213988105972156054969field $1 $2


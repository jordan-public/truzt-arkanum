#!/bin/zsh
set -e

if [ "$#" -ne 0 ]; then
    echo "Usage: $0"
    exit 1
fi

./get_wrapped_token_id.sh 1986245370112742436875568105128650176313749927841508924213988105972156054969field

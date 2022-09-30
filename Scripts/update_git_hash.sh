#!/bin/sh
filepath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}
PROJECT_DIR ?= "$(dirname $(dirname $(filepath $0)))"

# Hash (full length)
GITHASH=$(cd ${PROJECT_DIR} && git rev-parse HEAD)
echo "GIT_HASH=$GITHASH" > "${PROJECT_DIR}/Configuration/GitHash.xcconfig"

# Ignore the local chnage of GitHash.xcconfig
git update-index --assume-unchanged "${PROJECT_DIR}/Configuration/GitHash.xcconfig"

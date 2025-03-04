#!/bin/bash

ARCH=""

if [ $# -eq 0 ]; then
    ARCH="x86_64"
elif [ $1 = "arm" ]; then
    ARCH="arm64"
fi

echo "Building with arch: ${ARCH}"
echo "SwiftLint Version: $(swiftlint --version)"

export LC_CTYPE=en_US.UTF-8

set -o pipefail && env IDEFileSystemSynchronizedGroupsAreEnabled=YES arch -"${ARCH}" xcodebuild \
           -scheme CodeEdit \
           -destination "platform=OS X,arch=${ARCH}" \
           -skipPackagePluginValidation \
           clean test | xcpretty

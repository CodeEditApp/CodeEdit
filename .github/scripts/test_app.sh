#!/bin/bash

ARCH=""

if [ $# -eq 0 ]; then
    ARCH="x86_64"
elif [ $1 = "arm" ]; then
    ARCH="arm64"
fi

echo "Building with Xcode: $(xcodebuild -version)"
echo "Building with arch: ${ARCH}"
echo "SwiftLint Version: $(swiftlint --version)"

export LC_CTYPE=en_US.UTF-8

# xcbeautify flags: 
# - renderer: render to gh actions
# - q: quiet output
# - is-ci: include test results in output

set -o pipefail && arch -"${ARCH}" xcodebuild \
           -scheme CodeEdit \
           -destination "platform=OS X,arch=${ARCH}" \
           -skipPackagePluginValidation \
           clean test | xcbeautify --renderer github-actions -q --is-ci

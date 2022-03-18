#!/bin/bash

set -eo pipefail

xcodebuild -workspace CodeEdit.xcworkspace \
           -scheme CodeEdit \
           -destination 'platform=OS X,arch=x86_64' \
           clean test | xcpretty

#!/bin/bash

VERS=$(xcrun agvtool mvers -terse1)

if [ "$VERS" == "" ]; then
  echo "No version number found"
  echo "Make sure Info.plist has a CFBundleShortVersionString key"
  echo ""
  echo "If Info.plist does not have a CFBundleShortVersionString key, add the following to your Info.plist file:"
  echo ""
  echo "<key>CFBundleShortVersionString</key>"
  echo "<string>0.0.1</string>"
  echo ""
  echo "For more information see https://github.com/CodeEditApp/CodeEdit/pull/1006"
  exit 1
else
  echo "Version number is $VERS"
  exit 0
fi

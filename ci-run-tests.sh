#!/bin/bash

if [ -z "${DESTINATION_OS}" ] ; then DESTINATION_OS="8.2" ; fi
if [ -z "${DESTINATION_NAME}"] ; then DESTINATION_NAME="iPhone 6" ; fi

DESTINATION="platform=iOS Simulator,OS=${DESTINATION_OS},name=${DESTINATION_NAME}"

xctool \
    -workspace MaveSDK.xcworkspace \
    -scheme DemoApp \
    -configuration UnitTesting \
    -sdk iphonesimulator \
    -destination "${DESTINATION}" \
    test \
    -freshSimulator

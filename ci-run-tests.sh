#!/bin/bash

if [ -z "${DESTINATION_OS}" ] ; then DESTINATION_OS="8.2" ; fi
if [ -z "${DESTINATION_NAME}" ] ; then DESTINATION_NAME="iPhone 6" ; fi

DESTINATION="platform=iOS Simulator,OS=${DESTINATION_OS},name=${DESTINATION_NAME}"

echo "Running with destination ${DESTINATION}"

clean_and_build_tests() {
    xctool clean
    xctool \
        -workspace MaveSDK.xcworkspace \
        -scheme DemoApp \
        -configuration UnitTesting \
        -sdk iphonesimulator \
        -destination "${DESTINATION}" \
        build-tests
}

run_tests() {
    xctool run-tests -resetSimulator
}

clean_and_build_tests
RETURN_VAL=$?
[ $RETURN_VAL -ne 0 ] && echo "\n\n\n** EXITING BECAUSE BUILD-TESTS FAILED **\n\n" &&  exit 1

run_tests
RETURN_VAL=$?
[ $RETURN_VAL -eq 0 ] && exit 0

printf "\n\n\n** RUN-TESTS RETRYING 1 **\n\n"
run_tests
RETURN_VAL=$?
[ $RETURN_VAL -eq 0 ] && exit 0

printf "\n\n\n** RUN-TESTS RETRYING 2 **\n\n"
run_tests

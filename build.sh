#!/bin/bash
source functions.sh

COMPONENT_NAME=`getComponentName`
logInfoMessage "I'll retain only ${MAX_IMAGES} docker images of ${COMPONENT_NAME} "
sleep  $SLEEP_DURATION
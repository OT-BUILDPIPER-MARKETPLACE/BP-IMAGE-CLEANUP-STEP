#!/bin/bash
source functions.sh

STATUS="IN_PROGRESS"

if [ -z "$IMAGE_NAME" ]
then
    logInfoMessage "Image name is not provided in env variable $IMAGE_NAME checking it in BP data"
    IMAGE_NAME=`getComponentName`
    IMAGE_TAG=`getRepositoryTag`
fi

if [ -z "$IMAGE_NAME" ]
then
    logErrorMessage "Image name is not available in BP data as well please check!!!!!!"
    STATUS=ERROR
else
    logInfoMessage "I'll remove all prior tagged images of ${IMAGE_NAME}:${IMAGE_TAG}"
    sleep  $SLEEP_DURATION
fi


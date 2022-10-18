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
    TAGS_LIST=`getImageOlderTags nginx stable-alpine`
    removeImageTags ${IMAGE_NAME} "${TAGS_LIST}"
fi


function getImageOlderTags() {
    IMAGE_NAME=$1
    RECENT_TAG=$2
    docker images ${IMAGE_NAME} --filter "before=${IMAGE_NAME}:${RECENT_TAG}" --format "{{.Tag}}"
}

function removeImageTags() {
    IMAGE_NAME=$1
    TAGS_LIST="$2"

    for TAG in $TAGS_LIST
    do 
        echo "Removing image ${IMAGE_NAME}:${TAG}"
    done
}
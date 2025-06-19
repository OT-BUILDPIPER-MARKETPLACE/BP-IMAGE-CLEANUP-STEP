#!/bin/bash
source functions.sh
source log-functions.sh
source str-functions.sh
source file-functions.sh
source aws-functions.sh

IMAGE_NAME=`getComponentName`
IMAGE_TAG=`getRepositoryTag`

function getImageOlderTags() {
    IMAGE_NAME=$1
    RECENT_TAG=$2
    if [ -z "$RECENT_TAG" ]; then
        docker images "${IMAGE_NAME}" --format "{{.Tag}}"
    else
        docker images "${IMAGE_NAME}" --format "{{.Tag}}" | grep -v -x "${RECENT_TAG}"
    fi    
}

function removeImageTags() {
    IMAGE_NAME=$1
    TAGS_LIST="$2"

    for TAG in $TAGS_LIST
    do 
        logInfoMessage "Removing image ${IMAGE_NAME}:${TAG}"
        docker rmi -f ${IMAGE_NAME}:${TAG}
    done
}

if [ -z "$IMAGE_NAME" ] || [ -z "$IMAGE_TAG" ]
then
    logInfoMessage "Image name/tag is not provided in env variable $IMAGE_NAME checking it in BP data"
    logInfoMessage "Image Name -> $IMAGE_NAME"
    logInfoMessage "Image Tag -> $IMAGE_TAG"
fi

if [ -z "$IMAGE_NAME" ] || [ -z "$IMAGE_TAG" ]
then
    logErrorMessage "Image name/tag is not available in BP data please check!!!!!!"
    logInfoMessage "Image Name -> $IMAGE_NAME"
    logInfoMessage "Image Tag -> $IMAGE_TAG"
    TASK_STATUS=1
else
    logInfoMessage "I'll remove all prior tagged images of ${IMAGE_NAME}:${IMAGE_TAG}"
    sleep  $SLEEP_DURATION
    TAGS_LIST=`getImageOlderTags $IMAGE_NAME $IMAGE_TAG`
    removeImageTags $IMAGE_NAME "$TAGS_LIST"
    TASK_STATUS=0
fi


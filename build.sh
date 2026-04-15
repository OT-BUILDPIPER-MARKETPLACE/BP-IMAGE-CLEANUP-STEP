#!/bin/bash

source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh
source /opt/buildpiper/shell-functions/str-functions.sh
source /opt/buildpiper/shell-functions/file-functions.sh
source /opt/buildpiper/shell-functions/aws-functions.sh

IMAGE_NAME=`getComponentName`
IMAGE_TAG=`getRepositoryTag`

# 1. Initialization Phase
add_event "IMAGE CLEANUP INITIATED" "InProgress" \
          "Initializing old docker image cleanup process" \
          "Target Image: ${IMAGE_NAME:-UNKNOWN}"

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

# 2. Validation Phase
if [ -z "$IMAGE_NAME" ] || [ -z "$IMAGE_TAG" ]
then
    logInfoMessage "Image name or tag is not provided in environment variables. Checking BP data..."
    logInfoMessage "Image Name -> $IMAGE_NAME"
    logInfoMessage "Image Tag -> $IMAGE_TAG"
fi

# 3. Execution Phase
if [ -z "$IMAGE_NAME" ] || [ -z "$IMAGE_TAG" ]
then
    logErrorMessage "Image name or tag is missing from BP data. Cannot proceed with cleanup."
    logInfoMessage "Image Name -> $IMAGE_NAME"
    logInfoMessage "Image Tag -> $IMAGE_TAG"
    
    add_event "IMAGE CLEANUP COMPLETE" "Failed" \
              "Missing required Image Name or Tag" \
              "Action: Cleanup Aborted"
              
    TASK_STATUS=1
else
    logInfoMessage "Removing all prior tagged images for ${IMAGE_NAME}, retaining current tag: ${IMAGE_TAG}"
    sleep  $SLEEP_DURATION
    
    TAGS_LIST=`getImageOlderTags $IMAGE_NAME $IMAGE_TAG`
    removeImageTags $IMAGE_NAME "$TAGS_LIST"
    
    add_event "IMAGE CLEANUP COMPLETE" "Successful" \
              "Old docker images purged successfully" \
              "Retained Tag: ${IMAGE_TAG}"
              
    TASK_STATUS=0
fi
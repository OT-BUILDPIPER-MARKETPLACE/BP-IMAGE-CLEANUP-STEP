#!/bin/bash
source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh
source /opt/buildpiper/shell-functions/str-functions.sh
source /opt/buildpiper/shell-functions/file-functions.sh
source /opt/buildpiper/shell-functions/aws-functions.sh

TASK_STATUS=0

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
        logInfoMessage "Removing image ${IMAGE_NAME}:${TAG}"
        docker rmi -f ${IMAGE_NAME}:${TAG}
    done
}

if [ -z "$IMAGE_NAME" ] || [ -z "$IMAGE_TAG" ]
then
    logInfoMessage "Image name/tag is not provided in env variable $IMAGE_NAME checking it in BP data"
    logInfoMessage "Image Name -> ${IMAGE_NAME}"
    logInfoMessage "Image Tag -> ${IMAGE_TAG}"
    IMAGE_NAME=`getComponentName`
    IMAGE_TAG=`getRepositoryTag`
fi

if [ -z "$IMAGE_NAME" ] || [ -z "$IMAGE_TAG" ]
then
    logErrorMessage "Image name/tag is not available in BP data as well please check!!!!!!"
    logInfoMessage "Image Name -> ${IMAGE_NAME}"
    logInfoMessage "Image Tag -> ${IMAGE_TAG}"
    TASK_STATUS=1
else
    logInfoMessage "I'll remove all prior tagged images of ${IMAGE_NAME}:${IMAGE_TAG}"
    sleep  $SLEEP_DURATION
    TAGS_LIST=`getImageOlderTags nginx stable-alpine`
    removeImageTags ${IMAGE_NAME} "${TAGS_LIST}"
    TASK_STATUS=0
fi

saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}
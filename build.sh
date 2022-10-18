#!/bin/bash
source functions.sh

STATUS="IN_PROGRESS"

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
    IMAGE_NAME=`getComponentName`
    IMAGE_TAG=`getRepositoryTag`
fi

if [ -z "$IMAGE_NAME" ] || [ -z "$IMAGE_TAG" ]
then
    logErrorMessage "Image name/tag is not available in BP data as well please check!!!!!!"
    STATUS=ERROR
else
    logInfoMessage "I'll remove all prior tagged images of ${IMAGE_NAME}:${IMAGE_TAG}"
    sleep  $SLEEP_DURATION
    TAGS_LIST=`getImageOlderTags nginx stable-alpine`
    removeImageTags ${IMAGE_NAME} "${TAGS_LIST}"
    STATUS="success"
fi

if [ "$STATUS" = "success" ]
then
  logInfoMessage "Congratulations clean happenned susccessfully!!!"
  generateOutput ${ACTIVITY_SUB_TASK_CODE} true "Congratulations clean happenned susccessfully!!!"
elif [ $VALIDATION_FAILURE_ACTION == "FAILURE" ]
  then
    logErrorMessage "Please check logs for failure!!!"
    generateOutput ${ACTIVITY_SUB_TASK_CODE} false "Please check logs for failure!!!"
    echo "build unsucessfull"
    exit 1
   else
    logWarningMessage "Please check logs for failure!!!"
    generateOutput ${ACTIVITY_SUB_TASK_CODE} true "Please check logs for failure!!!"
fi
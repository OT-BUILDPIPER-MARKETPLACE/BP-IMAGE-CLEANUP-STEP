#!/bin/bash

source /opt/buildpiper/shell-functions/aws-functions.sh
source /opt/buildpiper/shell-functions/file-functions.sh
source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh
source /opt/buildpiper/shell-functions/str-functions.sh

IMAGE_NAME=$(getComponentName)
IMAGE_TAG=$(getRepositoryTag)

# 1. Initialization
logInfoMessage "> Starting step: image_cleanup"
logInfoMessage "> Target Image: ${IMAGE_NAME:-UNKNOWN}"

add_event "INITIALIZATION" "Successful" \
    "Image cleanup initialized" \
    "Target Image: ${IMAGE_NAME:-UNKNOWN}"

function getImageOlderTags() {
    local img=$1
    local recent=$2
    if [ -z "$recent" ]; then
        docker images "${img}" --format "{{.Tag}}"
    else
        docker images "${img}" --format "{{.Tag}}" | grep -v -x "${recent}"
    fi
}

function removeImageTags() {
    local img=$1
    local tags="$2"
    for TAG in $tags; do
        logInfoMessage "> Removing image ${img}:${TAG}"
        docker rmi -f "${img}:${TAG}"
        if [ $? -ne 0 ]; then
            logErrorMessage "> Failed to remove ${img}:${TAG}"
            return 1
        fi
    done
}

# 2. Validation
logInfoMessage "> Validating image name and tag..."

if [ -z "$IMAGE_NAME" ] || [ -z "$IMAGE_TAG" ]; then
    logInfoMessage "> Image name or tag not found in environment. Checking BP data..."
    logInfoMessage "> Image Name -> ${IMAGE_NAME}"
    logInfoMessage "> Image Tag  -> ${IMAGE_TAG}"
fi

if [ -z "$IMAGE_NAME" ] || [ -z "$IMAGE_TAG" ]; then
    logErrorMessage "> Image name or tag is missing. Cannot proceed with cleanup."
    logInfoMessage "> Image Name -> ${IMAGE_NAME}"
    logInfoMessage "> Image Tag  -> ${IMAGE_TAG}"

    add_event "IMAGE_CLEANUP_FAILED" "Failed" \
        "Missing required Image Name or Tag" \
        "Action: Cleanup Aborted"

    saveTaskStatus 1 ${ACTIVITY_SUB_TASK_CODE}
    exit 1
fi

logInfoMessage "> Validation passed: Image=${IMAGE_NAME} Tag=${IMAGE_TAG}"
add_event "VALIDATION" "Successful" \
    "Image name and tag validated" \
    "Image: ${IMAGE_NAME} | Tag: ${IMAGE_TAG}"

# 3. Pre-Cleanup Summary
TAGS_LIST=$(getImageOlderTags "$IMAGE_NAME" "$IMAGE_TAG")
TAG_COUNT=$(echo "$TAGS_LIST" | grep -c . || true)
[ -z "$TAGS_LIST" ] && TAGS_DISPLAY="none (no older tags found)" || TAGS_DISPLAY="$TAGS_LIST"
[ -z "$TAGS_LIST" ] && TAG_COUNT=0

echo ""
echo "> Pre-Cleanup Summary"
printf '+%-25s+%-55s+\n' '-------------------------' '-------------------------------------------------------'
printf '| %-23s | %-53s |\n' "Parameter" "Value"
printf '+%-25s+%-55s+\n' '-------------------------' '-------------------------------------------------------'
printf '| %-23s | %-53s |\n' "Image Name" "${IMAGE_NAME}"
printf '+%-25s+%-55s+\n' '-------------------------' '-------------------------------------------------------'
printf '| %-23s | %-53s |\n' "Retained Tag" "${IMAGE_TAG}"
printf '+%-25s+%-55s+\n' '-------------------------' '-------------------------------------------------------'
printf '| %-23s | %-53s |\n' "Tags to Remove" "${TAG_COUNT}"
printf '+%-25s+%-55s+\n' '-------------------------' '-------------------------------------------------------'
printf '| %-23s | %-53s |\n' "Tags" "${TAGS_DISPLAY:0:53}"
printf '+%-25s+%-55s+\n' '-------------------------' '-------------------------------------------------------'
echo ""

add_event "IMAGE_CLEANUP_START" "Successful" \
    "Initializing cleanup for old image tags" \
    "Image: ${IMAGE_NAME} | Tags to Remove: ${TAG_COUNT}"

# 4. Execution
logInfoMessage "> Removing all prior tagged images for ${IMAGE_NAME}, retaining: ${IMAGE_TAG}"
sleep "$SLEEP_DURATION"

removeImageTags "$IMAGE_NAME" "$TAGS_LIST"

if [ $? -ne 0 ]; then
    logErrorMessage "> Cleanup failed for ${IMAGE_NAME}"
    add_event "IMAGE_CLEANUP_FAILED" "Failed" \
        "Error while removing image tags" \
        "Check logs for: ${IMAGE_NAME}"
    saveTaskStatus 1 ${ACTIVITY_SUB_TASK_CODE}
    exit 1
fi

# 5. Post-Cleanup Summary
REMAINING_TAGS=$(getImageOlderTags "$IMAGE_NAME" "$IMAGE_TAG" | grep -c . || true)

echo ""
echo "> Post-Cleanup Summary"
printf '+%-25s+%-55s+\n' '-------------------------' '-------------------------------------------------------'
printf '| %-23s | %-53s |\n' "Parameter" "Value"
printf '+%-25s+%-55s+\n' '-------------------------' '-------------------------------------------------------'
printf '| %-23s | %-53s |\n' "Image Name" "${IMAGE_NAME}"
printf '+%-25s+%-55s+\n' '-------------------------' '-------------------------------------------------------'
printf '| %-23s | %-53s |\n' "Tags Removed" "${TAG_COUNT}"
printf '+%-25s+%-55s+\n' '-------------------------' '-------------------------------------------------------'
printf '| %-23s | %-53s |\n' "Remaining Old Tags" "${REMAINING_TAGS}"
printf '+%-25s+%-55s+\n' '-------------------------' '-------------------------------------------------------'
printf '| %-23s | %-53s |\n' "Retained Tag" "${IMAGE_TAG}"
printf '+%-25s+%-55s+\n' '-------------------------' '-------------------------------------------------------'
printf '| %-23s | %-53s |\n' "Status" "SUCCESS"
printf '+%-25s+%-55s+\n' '-------------------------' '-------------------------------------------------------'
echo ""

add_event "IMAGE_CLEANUP_COMPLETE" "Successful" \
    "Old docker images purged successfully" \
    "Image: ${IMAGE_NAME} | Retained Tag: ${IMAGE_TAG}"

sleep "$SLEEP_DURATION"
saveTaskStatus 0 ${ACTIVITY_SUB_TASK_CODE}

#!/bin/bash

#
# this script pops the last docker image depending on the desired length of the setup
#

CURRENT_IMAGE=$1
SAVED_IMAGE_LENGTH=$2

function pop_last_image() {

    IFS=':' read -ra prefix <<< "$CURRENT_IMAGE"

    last_sha=$(head -n $SAVED_IMAGE_LENGTH ~/.var/deploy/logs/sha-stack.txt  | awk '{print $1}')
    logcount=$(head -n $SAVED_IMAGE_LENGTH ~/.var/deploy/logs/sha-stack.txt  | awk '{print $1}'| awk 'END{print NR}')

    IMAGE_TO_POP="$prefix:$last_sha"

    if [[ $logcount -eq $SAVED_IMAGE_LENGTH ]]; then
        if [[ $CURRENT_IMAGE == $IMAGE_TO_POP ]]; then
            docker rm $IMAGE_TO_POP || true
            echo "[DELETED] $IMAGE_TO_POP has been remove from images"
        else
            echo "[WARN] $IMAGE_TO_POP could not be deleted from images"
        fi
    else
        echo "Could not pop docker image stack, LOG_COUNT: $logcount"
    fi

}



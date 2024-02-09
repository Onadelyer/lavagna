#!/bin/bash

LOCK_FILE="/tmp/cleanup.lock"

# Check if lock file exists
if [ -f "$LOCK_FILE" ]; then
    exit 0
fi

# Create lock file
touch "$LOCK_FILE"

# Function to remove lock file on exit
cleanup() {
    rm -f "$LOCK_FILE"
}

# Trap cleanup function on EXIT signal
trap cleanup EXIT

stop_all_containers() {
    running_containers=$(docker ps -q)
    if [ -n "$running_containers" ]; then
        docker stop $running_containers
    fi
}

remove_all_containers() {
    all_containers=$(docker ps -aq)
    if [ -n "$all_containers" ]; then
        docker rm $all_containers
    fi
}

remove_all_images() {
    all_images=$(docker images -aq)
    if [ -n "$all_images" ]; then
        docker rmi $all_images
    fi
}

stop_all_containers
remove_all_containers
remove_all_images

docker system prune -f
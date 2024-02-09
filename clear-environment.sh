#!/bin/bash

stop_all_containers() {
    running_containers=$(docker ps -q)
    if [ -n "$running_containers" ]; then
        docker stop $running_containers
}

remove_all_containers() {
    all_containers=$(docker ps -aq)
    if [ -n "$all_containers" ]; then
        docker rm $all_containers
}

remove_all_images() {
    all_images=$(docker images -aq)
    if [ -n "$all_images" ]; then
        docker rmi $all_images
}

stop_all_containers

remove_all_containers

remove_all_images
#!/bin/bash

if [ -n "$(docker ps -q)" ]; then
    docker stop $(docker ps -aq)
fi

if [ -n "$(docker ps -aq)" ]; then
    docker rm $(docker ps -aq)
fi

if [ -n "$(docker images -q)" ]; then
    docker rmi $(docker images -q) -f
fi

#docker system prune -f
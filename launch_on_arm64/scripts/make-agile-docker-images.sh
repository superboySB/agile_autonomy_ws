#!/bin/bash
source config.sh
TAG=0.0.0
if [ "$1" != "" ] ;then
	TAG=$1
fi

docker build -t ${DOCKER_IMAGE_NAME}:${TAG} -f ${DOCKERFILE_NAME} .

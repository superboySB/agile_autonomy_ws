#!/bin/bash

#### Configure it before run ####
#Used to detect current computer's ip address

source config.sh
#Used to find docker's tag,can be overwrited with offerered tag:run.sh 0.1.0 for example
TAG=0.0.0
IMAGE_NAME=qiyuan-agile-ros
################################

if [ "$1" != "" ] ;then
	TAG=$1
	shift
fi

IMG_HASH=$(docker images | grep $IMAGE_NAME | awk -F" " -v tag="$TAG" '{ if( $2==tag){ print $3} }')

if [ -z $IMG_HASH ] ;then
	echo "[FAIL] Find no docker image called : $IMAGE_NAME:$TAG"
	echo "Have a try below"
	echo "-----------------"
	docker images | grep $IMAGE_NAME
else
	xhost +
	project_path=$(dirname $0 | cd | pwd | xargs dirname)

	if [ "${MULTITERMINAL}" = "true" ] ;then
		gnome-terminal -- sh -c "echo Waiting for agile-master to run...;sleep ${WAIT_TIME_SECONDS};docker exec -ti agile-${tag} /bin/bash" &
		gnome-terminal -- sh -c "echo Waiting for agile-master to run...;sleep ${WAIT_TIME_SECONDS};docker exec -ti agile-${tag} /bin/bash" &
		gnome-terminal -- sh -c "echo Waiting for agile-master to run...;sleep ${WAIT_TIME_SECONDS};docker exec -ti agile-${tag} /bin/bash" &
	fi

	IS_AGILE_RUNNING=$( docker ps -a | grep ${DOCKER_CONTAINER_PREFIX}-${TAG} )
	if [ -z "$IS_AGILE_RUNNING" -o "$1" = "-f" ] ;then
		docker rm -f ${DOCKER_CONTAINER_PREFIX}-${TAG} 2>/dev/null
		docker  run --privileged \
			--gpus all --runtime nvidia -it --network host \
			--name ${DOCKER_CONTAINER_PREFIX}-${TAG} \
			-p 2222:2222 \
			-e CUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-10.2 \
			-e DISPLAY=$DISPLAY \
			-v ${project_path}:/var/files \
			-v /tmp/.X11-unix:/tmp/.X11-unix \
			-w /var/files/scripts \
			--entrypoint=/var/files/scripts/entrypoint.sh \
			$IMAGE_NAME:${TAG}
	else
		docker start -ai ${DOCKER_CONTAINER_PREFIX}-${TAG}
	fi
fi

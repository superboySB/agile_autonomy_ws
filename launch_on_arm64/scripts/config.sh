
# if just run on local,set it with "true",others means false
export SINGLE_NODE=true
# if $SINGLE_NODE was set with "true",this should be the other node's ip
export NODE_OTHER_IP=0.0.0.0
export MASTER_URI=http://hostname_A:11311
export HOST_NAME=hostname_A
# if you want to use other network interface to bind,change it
export INTERFACE=eth0
export WAIT_TIME_SECONDS=5
# set to "true" if want to run entrypoint.sh
export RUN_WHEN_START=false
export COMMAND=bash
export MULTITERMINAL=false

if [ "${SINGLE_NODE}" = "true" ] ;then
    LOCAL_IP=127.0.0.1
else
    LOCAL_IP=$(ip -4 -br  addr | grep ${INTERFACE} | awk  'BEGIN{FS="[ /]+"}{ print $3}')
fi
export ROS_IP=${LOCAL_IP}

############NO CHANGE
export DOCKER_IMAGE_NAME=qiyuan-agile-ros
export DOCKER_CONTAINER_PREFIX=agile-ros
export DOCKERFILE_NAME=agile-ros.dockerfile
############NO CHANGE


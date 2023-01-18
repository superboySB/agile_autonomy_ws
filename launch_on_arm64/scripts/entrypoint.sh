#!/bin/bash

source config.sh
# Add environment variables (Careful! Modify path according to your local setup)
if [ ! -f "/root/.xyz" ] ;then
	echo "export RPGQ_PARAM_DIR=/var/files/workspace/agile_autonomy_ws/catkin_aa/src/rpg_flightmare" >> ~/.bashrc
	ROS_SETUP=/opt/ros/melodic/setup.bash
	if [ -f "${ROS_SETUP}" ] ;then
	    echo "source ${ROS_SETUP}" >> ~/.bashrc 
	    source ${ROS_SETUP}  --extend
	fi

	REALSENSE_SETUP=/var/files/test-realsense/devel/setup.bash
	if [ -f "${REALSENSE_SETUP}" ] ;then
	    echo "source ${REALSENSE_SETUP}" >> ~/.bashrc 
	    source ${REALSENSE_SETUP}  --extend
	fi

	AGILE_SETUP=/var/files/workspace/agile_autonomy_ws/catkin_aa/devel/setup.bash
	if [ -f "${AGILE_SETUP}" ] ;then
	    echo "source ${AGILE_SETUP}" >> ~/.bashrc 
	    source ${AGILE_SETUP}  --extend
	fi

	CVBRIDGE_SETUP=/var/files/workspace/cv_bridge_ws/devel/setup.bash
	if [ -f "${CVBRIDGE_SETUP}" ] ;then
	    echo "source ${CVBRIDGE_SETUP}" >> ~/.bashrc 
	    source ${CVBRIDGE_SETUP} --extend
	fi

	if [ ${SINGLE_NODE} != "true" ] ;then
	    echo "${ROS_IP} hostname_A" >> /etc/hosts
	    echo "${NODE_OTHER_IP} hostname_B" >> /etc/hosts
	    echo "export ROS_HOSTNAME=${HOST_NAME}" >> ~/.bashrc 
	    echo "export ROS_MASTER_URI=${MASTER_URI}" >> ~/.bashrc 
	    echo "export ROS_IP=${ROS_IP}" >> ~/.bashrc 
	fi
	touch /root/.xyz
fi

if [ "${RUN_WHEN_START}" = "true" ] ;then
    service ssh start && bash -c $COMMAND
else
    service ssh start && bash
fi

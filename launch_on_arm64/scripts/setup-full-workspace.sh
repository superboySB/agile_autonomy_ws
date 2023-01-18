#!/bin/bash
if [ "$1" = "" -o "$1" = "-h" ] ;then
    	echo "setup-full-workspace.sh all   : Build open3d,cv_bridge,agile-autonomy"
    	echo "setup-full-workspace.sh agile : Only agile-autonomy"
    	echo "setup-full-workspace.sh cv : Only build cv-bridge"
	echo "setup-full-workspace.sh open3d : Only build open3d"
fi

export ROS_VERSION=melodic
mkdir -p /var/files/workspace 2>/dev/null
cd /var/files/workspace
### build open3d from source ###
if [ "$1" = "all" -o "$1" = "open3d" ] ;then
	OPEN3D_WS=open3d_ws/build
	rm -rf ${OPEN3D_WS} 2>/dev/null
	mkdir -p ${OPEN3D_WS}
	cd ${OPEN3D_WS} 
	cp -r /var/files/src/open3d_src ../
	cmake -DCMAKE_BUILD_TYPE=release ../open3d_src
	make -j4
	make install
	cp -r /usr/local/include/Open3D/3rdparty/* /usr/include/
fi
### build cv_bridge ###
if [ "$1" = "all" -o "$1" = "cv" ] ;then
	CV_WS=/var/files/workspace/cv_bridge_ws
	if [ ! -d "${CV_WS}" ] ;then
		mkdir -p cv_bridge_ws
		cp -r /var/files/src/cv_bridge_src ${CV_WS}/src
	fi
	cd cv_bridge_ws && catkin config --install && catkin config -DPYTHON_EXECUTABLE=/usr/bin/python3 -DPYTHON_INCLUDE_DIR=/usr/include/python3.6m -DPYTHON_LIBRARY=/usr/lib/aarch64-linux-gnu/libpython3.6m.so && catkin build
fi
### build agile ###
if [ "$1" = "all" -o "$1" = "agile" ] ;then
	AGILE_WS=agile_autonomy_ws
	if [ ! -d "${AGILE_WS}" ];then
		mkdir -p ${AGILE_WS}/catkin_aa
		cp -r /var/files/src/agile_src  ${AGILE_WS}/catkin_aa/src
	fi
	cd ${AGILE_WS}/catkin_aa
	catkin init
	catkin config --extend /opt/ros/$ROS_VERSION
	catkin config --merge-devel
	catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=-fdiagnostics-color
	cd src
	catkin build
fi

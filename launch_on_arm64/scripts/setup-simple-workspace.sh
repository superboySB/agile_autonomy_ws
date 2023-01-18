#!/bin/bash
if [ -d "/var/files/workspace/open3d-build" ] ;then
	cd /var/files/workspace/open3d_ws/build && make install
	cp -r /usr/local/include/Open3D/3rdparty/* /usr/include/
elif [ -d "/var/files/resources" ] ;then
	cd /var/files/resources/open3d-build/ && make install
	if [ ! -d "/var/files/workspace/cv_bridge_ws" ] ;then
		cp -r /var/files/resources/cv_bridge_ws_melodic /var/files/workspace/cv_bridge_ws
	fi
	if [ ! -d "/var/files/workspace/agile_autonomy_ws" ] ;then
		cp -r /var/files/resources/agile_autonomy_ws_melodic /var/files/workspace/agile_autonomy_ws
	fi
else
	echo "[Error]Cannot find resources/ or workspace/ in /var/files"
fi

FROM nvcr.io/nvidia/l4t-tensorflow:r32.6.1-tf2.5-py3

RUN sed -i "s@http://.*archive.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list && \
sed -i "s@http://ports.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' > /etc/timezone  && \
apt update && apt install -y gpg curl software-properties-common python3.7 python3-pip openssh-server net-tools && \
sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config && echo "root:root" | chpasswd && \
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/'  /etc/ssh/sshd_config && \
sed -i 's/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/' /etc/ssh/sshd_config && \
sed -i 's/#AddressFamily any/AddressFamily any/' /etc/ssh/sshd_config && \
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config

COPY ./ros.asc /var/ros.asc 

RUN echo "deb http://packages.ros.org/ros/ubuntu bionic main" > /etc/apt/sources.list.d/ros-latest.list  && \ 
apt-key add /var/ros.asc && apt update && \ 
apt install -y libsdl1.2-dev libsdl-image1.2-dev  desktop-file-utils lsb-core  && \
apt upgrade libstdc++6 -y && \
python3 -m pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple && \
pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

RUN apt install -y ros-melodic-desktop-full && \
#install extra dependencies (might need more depending on your OS)
apt install libqglviewer-dev-qt5 -y && \
# Install external libraries for rpg_flightmare
apt install -y libzmqpp-dev libeigen3-dev libglfw3-dev libglm-dev

RUN apt install -y libvulkan1 vulkan-utils gdb && \
apt install -y libgl1-mesa-dev && \
apt install -y git iputils-ping vim  && \
apt install -y xorg-dev libglu1-mesa-dev libgl1-mesa-glx || true  && \
apt install -y libglew-dev || true  && \
apt install -y libglfw3-dev || true  && \
apt install -y libeigen3-dev || true  && \
apt install -y libpng-dev || true  && \
apt install -y libpng16-dev || true  && \
apt install -y libsdl2-dev || true  && \
apt install -y python-dev python-tk || true  && \
apt install -y python3-dev python3-tk || true  && \
apt install -y libtbb-dev || true  && \
apt install -y libglu1-mesa-dev || true  && \
apt install -y libc++-7-dev || true  && \
apt install -y libc++abi-7-dev || true  && \
apt install -y ninja-build || true  

RUN apt install -y ros-melodic-octomap-msgs && \
apt install -y ros-melodic-octomap-mapping  && \
apt install -y ros-melodic-librealsense2 && \
apt install -y ros-melodic-realsense2-camera

RUN pip3 install -U vcstool catkin_tools Cython numpy==1.19.4 -i https://pypi.tuna.tsinghua.edu.cn/simple

RUN pip3 install rospkg==1.2.3 pyquaternion -i https://pypi.tuna.tsinghua.edu.cn/simple 

# realsense about
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE || sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE && \
add-apt-repository "deb https://librealsense.intel.com/Debian/apt-repo $(lsb_release -cs) main" -u && \
apt update && \
apt-get install -y librealsense2-utils librealsense2-dev librealsense2-dbg

RUN apt install -y iproute2 python3.7-dev 

ENTRYPOINT service ssh start && bash

# && add-apt-repository ppa:ubuntu-toolchain-r/test 
#RUN mkdir -p cv_bridge_ws/src && cd cv_bridge_ws/src && git clone https://ghproxy.com/https://github.com/ros/catkin.git && git clone https://ghproxy.com/https://github.com/ros-#perception/vision_opencv.git && apt-cache show ros-melodic-cv-bridge | grep Version && cd vision_opencv && git checkout 1.13.0 && cd ../../ && catkin config --install && catkin config -#DCMAKE_PREFIX_PATH=/opt/ros/melodic/share -DPYTHON_EXECUTABLE=/usr/bin/python3 -DPYTHON_INCLUDE_DIR=/usr/include/python3.6m -DPYTHON_LIBRARY=/usr/lib/aarch64-linux-gnu/libpython3.6m.so #&& catkin build && source install/setup.bash --extend

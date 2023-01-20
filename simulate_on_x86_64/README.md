Note for runing codes in x86_64 machines

# Requirements
Preferred: An x86_64 workstation + Ubuntu 20.04 + RTX 3090

## Install joy in the **localhost** machine (Necessary for VELOCITY_CONTROL mode)
```sh
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'

sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

sudo apt update
sudo apt install ros-noetic-desktop-full
source /opt/ros/noetic/setup.bash

sudo apt-get install ros-noetic-joy
sudo apt-get install ros-noetic-joystick-drivers
```

## Enabling Jetson Containers on an x86 workstation (Optional)
One of the very cool features that are now enabled is the ability to build Arm CUDA binaries on your x86 machine without needing a cross compiler. You can very easily run AArch64 containers on your x86 workstation by using qemu’s virtualization features. This section will go over the steps to enable that. The next section will go over the workflow that allows you to build on x86 and then run on Jetson. Installing the following packages should allow you to enable support for AArch64 containers on x86:
```sh
$ sudo apt-get install qemu binfmt-support qemu-user-static

# Check if the entries look good.
$ sudo cat /proc/sys/fs/binfmt_misc/status
enabled

# See if /usr/bin/qemu-aarch64-static exists as one of the interpreters.
$ cat /proc/sys/fs/binfmt_misc/qemu-aarch64
enabled
interpreter /usr/bin/qemu-aarch64-static
flags: OCF
offset 0
magic 7f454c460201010000000000000000000200b700
mask ffffffffffffff00fffffffffffffffffeffffff
```
Make sure the F flag is present, if not head to the troubleshooting section, as this will result in a failure to start the Jetson container. You’ll usually find errors in the form: exec user process caused "exec format error"

# Configure the enironment
##  Build a nvidia docker
```sh
# Clone a docker file
cd ~ && git clone https://LeakyCauldronTHU@bitbucket.org/LeakyCauldronTHU/ros-docker-gui.git

# Build a docker image
cd ~/ros-docker-gui && make nvidia_ros_melodic_cuda11-4-2_cudnn8

# Load an image (if an image has been loaded from another machine)
docker load < <IMAGENAME>.tar

# Open X11 at first
xhost +

# Run a container
docker run -it --privileged --net=host --ipc=host --device=/dev/dri:/dev/dri -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY -e ROS_IP=127.0.0.1 --gpus all --name debug ros/melodic:v1 /bin/bash
```

## Install dependencies (e.g., vscode, tensorflow)
```sh
sudo apt-get update && sudo apt-get install git python3-pip lsb-core vim gedit locate python-catkin-tools wget desktop-file-utils python3-empy python3-vcstool gcc g++ cmake git gnuplot doxygen graphviz software-properties-common apt-transport-https curl -y && curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - && sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" && sudo apt update && sudo apt install code -y && sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y && sudo apt upgrade libstdc++6 -y && pip3 install -U pip -i https://pypi.tuna.tsinghua.edu.cn/simple && pip3 install tensorflow-gpu==2.5 rospkg==1.2.3 pyquaternion open3d opencv-python catkin_pkg vcstool aiohttp -i https://pypi.tuna.tsinghua.edu.cn/simple
```

## Download apps from gitee (faster)
```sh
cd ~ && git clone https://gitee.com/superboySB/agile_autonomy_dependencies.git && tar -C ~/agile_autonomy_dependencies/ -zxvf ~/agile_autonomy_dependencies/standalone.tgz
```

## Install open3d
```sh
tar -C ~/ -zxvf ~/agile_autonomy_dependencies/Open3D.tgz && cd ~/Open3D/ && util/scripts/install-deps-ubuntu.sh assume-yes && mkdir build && cd build && cmake -DBUILD_SHARED_LIBS=ON .. && make -j16 && sudo make install
```

## Install cv_bridge
Note that x86_64 should be replaced by aarch64 in embedded systems (e.g., Jetson)
```
mkdir -p ~/cv_bridge_ws/src && tar -C ~/cv_bridge_ws/src/ -zxvf ~/agile_autonomy_dependencies/vision_opencv.tgz && apt-cache show ros-melodic-cv-bridge | grep Version && cd ~/cv_bridge_ws/ && catkin config --install && catkin config -DPYTHON_EXECUTABLE=/usr/bin/python3 -DPYTHON_INCLUDE_DIR=/usr/include/python3.6m -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.6m.so && catkin build && source install/setup.bash --extend
```

## Compile our project
Load Unity-3D simulation data at first, by downlaoding the flightmare standalone (Default:[X86_64](https://zenodo.org/record/5517791/files/standalone.tar?download=1), or recompile it in other platforms), extract it and put it in the "rpg_flightmare/flightrender/". We have finished the above process, so we only need to run:
```sh
sudo apt-get install libqglviewer-dev-qt5 libzmqpp-dev libeigen3-dev libglfw3-dev libglm-dev libvulkan1 vulkan-utils gdb ros-melodic-octomap-msgs libsdl-image1.2-dev libsdl-dev ros-melodic-octomap ros-melodic-octomap-mapping ros-melodic-octomap-msgs libgoogle-glog-dev -y
```
```
cd ~ && git clone https://github.com/superboySB/agile_autonomy_ws.git && mv ~/agile_autonomy_dependencies/standalone/20201127/* ~/agile_autonomy_ws/src/rpg_flightmare/flightrender/ && chmod 777 -R ~/agile_autonomy_ws/src/rpg_flightmare/flightrender && echo 'export RPGQ_PARAM_DIR=~/agile_autonomy_ws/src/rpg_flightmare' >> ~/.bashrc && source ~/.bashrc
```
Note that x86_64 should be replaced by aarch64 in embedded systems (e.g., Jetson)
```
cd ~/agile_autonomy_ws && catkin init && catkin config --extend /opt/ros/melodic && catkin config --merge-devel && catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=-fdiagnostics-color && catkin config -DPYTHON_EXECUTABLE=/usr/bin/python3 -DPYTHON_INCLUDE_DIR=/usr/include/python3.6m -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.6m.so && catkin build
```
Before you finally launch the project, restart the container/machine is recommanded. 

# Launch the project
## Open a terminal for simulation (velocity control)
```sh
cd ~/agile_autonomy_ws && source devel/setup.sh

roslaunch agile_autonomy simulation.launch
```

## Open a new terminal (test AI-based navigation)
```sh
cd ~/agile_autonomy_ws && source devel/setup.sh && source ../cv_bridge_ws/install/setup.sh --extend

roscd planner_learning && python3 test_trajectories.py --settings_file=config/test_settings.yaml
```

# Debug the project
## Recompile Quadrotor model (Necessary for applying MPC in real application)
```sh
cd ~ && git clone https://github.com/acado/acado.git -b stable ACADOtoolkit

cd ~/ACADOtoolkit && mkdir build && cd build && cmake .. && make && cd .. && cd examples/getting_started && ./simple_ocp

source /home/qiyuan/ACADOtoolkit/build/acado_env.sh
```
Modify our model `quadrotor_model_thrustrates.cpp` for MPC, and then rebuild:
```sh
# generate quadrotor_model_codegen
cd ~/agile_autonomy_ws/src/rpg_mpc/model/ && cmake . && make

# generate quadrotor_mpc_codegen
./quadrotor_model_codegen
```
Next, modify `parameters` in `rpg_quadrotor_control/simulation/rpg_rotors_interface`.

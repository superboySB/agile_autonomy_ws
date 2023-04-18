Note for runing codes in x86_64 machines

# Requirements
Preferred: An x86_64 workstation + Ubuntu 20.04 (ROS-Noetic)+ RTX 3090

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
sudo apt-get update && sudo apt-get install git python3-pip lsb-core vim gedit locate python-catkin-tools wget desktop-file-utils python3-empy python3-vcstool gcc g++ cmake git gnuplot doxygen graphviz software-properties-common apt-transport-https curl -y && curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - && sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" && sudo apt update && sudo apt install code -y && sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y && sudo apt upgrade libstdc++6 -y && pip3 install -U pip -i https://pypi.tuna.tsinghua.edu.cn/simple && pip3 install tensorflow-gpu==2.5 rospkg==1.2.3 pyquaternion open3d opencv-python catkin_pkg vcstool netifaces aiohttp -i https://pypi.tuna.tsinghua.edu.cn/simple && echo 'set-option -g default-shell /bin/bash' >> ~/.tmux.conf
```

## Download apps from our pre-built version (faster)
Download several essential apps from [our pre-built copies (online supported by OneDrive)](https://superboysb-my.sharepoint.cn/:f:/g/personal/admin_superboysb_partner_onmschina_cn/Eiay3rqvyGJBn9FubguX6E8BRw5kl5M_5XiHmc_OUlQ7WA?e=qa1u2s), inluding: 1) pre-built ROS container; 2) pre-compiled Open3D+cv_bridge; 3) the Unity-3D flightmare standalone. Then, you can run:

```sh
docker cp /home/xxx/Downloads/agile_autonomy_dependencies debug:/home/qiyuan/
```

```sh
cd ~ && tar -C ~/agile_autonomy_dependencies/ -zxvf ~/agile_autonomy_dependencies/standalone.tgz
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
sudo apt-get install libqglviewer-dev-qt5 libzmqpp-dev libeigen3-dev libglfw3-dev libglm-dev libvulkan1 vulkan-utils gdb ros-melodic-octomap-msgs libsdl-image1.2-dev libsdl-dev ros-melodic-octomap ros-melodic-octomap-mapping ros-melodic-octomap-msgs libgoogle-glog-dev -y && echo 'export RPGQ_PARAM_DIR=~/agile_autonomy_ws/src/rpg_flightmare' >> ~/.bashrc
```
**Every time when you change the code in other machines**, you can delete the project and then restart by:
```sh
cd ~ && git clone https://github.com/superboySB/agile_autonomy_ws.git
```
```sh
cp -r ~/agile_autonomy_dependencies/standalone/20201127/* ~/agile_autonomy_ws/src/rpg_flightmare/flightrender/ && chmod 777 -R ~/agile_autonomy_ws/src/rpg_flightmare/flightrender && source ~/.bashrc
```
Below is built on x86_64 Linux OS platform. Note that x86_64 should be replaced by aarch64 in embedded systems (e.g., Jetson)
```
cd ~/agile_autonomy_ws && catkin init && catkin config --extend /opt/ros/melodic && catkin config --merge-devel && catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=-fdiagnostics-color && catkin config -DPYTHON_EXECUTABLE=/usr/bin/python3 -DPYTHON_INCLUDE_DIR=/usr/include/python3.6m -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.6m.so && catkin build
```
Before you finally launch the project, restart the container/machine is recommanded. 

# Let's Fly!
## Test on Flightmare Simulation
Open a terminal for simulation (mode: position control/velocity control)
```sh
cd ~/agile_autonomy_ws && source devel/setup.sh
```
```sh
roslaunch agile_autonomy simulation.launch
```
Open a new terminal (mode: feedforward)
```sh
cd ~/agile_autonomy_ws && source devel/setup.sh && source ../cv_bridge_ws/install/setup.sh --extend
```
```sh
roscd planner_learning && python3 test_trajectories.py --settings_file=config/test_settings.yaml
```
## Test on Real Deployment [Need to RE-implement]
Todo

# Train your own navigation policy
You can use the following commands to generate data in simulation and train your model on it. Note that training a policy from scratch could require a lot of data, and depending on the speed of your machine this could take several days. Therefore, we always recommend finetuning the provided checkpoint to your use case. As a general rule of thumb, you need a dataset with comparable size to ours to train a policy from scratch, but only 1/10th of it to finetune.

## Single Machine
To train or finetune a policy, use the following commands: Launch the simulation in one terminal
```sh
cd ~/agile_autonomy_ws && source devel/setup.bash
```
```sh
roslaunch agile_autonomy simulation.launch
```
Launch data collection (with dagger) in an other terminal
```sh
cd ~/agile_autonomy_ws && source devel/setup.bash && source ../cv_bridge_ws/install/setup.sh --extend
```
```sh
roscd planner_learning && python3 dagger_training.py --settings_file=config/dagger_settings.yaml
```


## Distributed Training [Need to RE-implement]
If you want to use the communication of the two local machines, please add these environmental variables to your `bashrc` (default ip is `localhost`):
```
export ROS_IP=[slaver_ip]
export ROS_MASTER_URI=http://[master_ip]:11311
export ROS_HOSTNAME=$ROS_IP
```
And then the master machine can run in two shells:
```sh
cd ~/agile_autonomy_ws && source devel/setup.bash && roslaunch agile_autonomy master.launch
```
```sh
cd ~/agile_autonomy_ws && source devel/setup.bash && source ../cv_bridge_ws/install/setup.sh --extend && roscd planner_learning && python3 dagger_training_master.py --settings_file=config/dagger_settings.yaml
```
Likewise, the slaver machine can run:
```sh
cd ~/agile_autonomy_ws && source devel/setup.bash && source ../cv_bridge_ws/install/setup.sh --extend && roslaunch agile_autonomy slaver.launch
```
```sh
cd ~/agile_autonomy_ws && source devel/setup.bash && source ../cv_bridge_ws/install/setup.sh --extend && roscd planner_learning && python3 dagger_training_slaver.py --settings_file=config/dagger_settings.yaml
```



# TroubleShooting
## Q&A

1. git clone is very slow

```sh
# set
git config --global http.https://github.com.proxy socks5://127.0.0.1:<proxy-port>

# unset
git config --global --unset http.proxy && git config --global --unset https.proxy

# buffer
git config --global http.postBuffer 524288000
```


2. Recompile Quadrotor model. It is necessary for changing hyper parameters of MPC in real application.
Install the package
```sh
cd ~ && git clone https://github.com/acado/acado.git -b stable ACADOtoolkit && cd ~/ACADOtoolkit && mkdir build && cd build && cmake .. && make && cd .. && cd examples/getting_started && ./simple_ocp
```
It means successful by seeing a plotted window. **Every time when we want to recompile quadrotor model**, we need to start by:
```
source /home/qiyuan/ACADOtoolkit/build/acado_env.sh
```
Delete `quadrotor_model_codegen` and `quadrotor_mpc_codegen` in `rpg_mpc/model/`. Then, we can modify our model in `quadrotor_model_thrustrates.cpp` and rebuild:
```sh
# generate quadrotor_model_codegen
cd ~/agile_autonomy_ws/src/rpg_mpc/model/ && cmake . && make

# generate quadrotor_mpc_codegen
./quadrotor_model_codegen
```
Next, we also need to modify `parameters` in `rpg_quadrotor_control/simulation/rpg_rotors_interface`.

3. Tips of Deployment

* Can not find our on-board resources 
```sh
vim /etc/hosts
## Add:
## 192.168.1.111 TX2
## 192.168.1.100 GCS
```

* Pipelines (based on my memory, not percisely)
```sh
## autopilot
roslaunch qiyuan-rpg launch_files/archaeopteryx.launch

## simulation
roslaunch agile_autonomy master.launch

## python files
source devel/setup.bash && source cv_bridge_ws/install/setup.sh --extend && roscd planner_learning && python3 deployment.py --deployment_settings.yaml

# rviz
roslaunch rviz
```

* Numpy core-down
```sh
## Add to ~/.bashrc
export OPENBLAS_CORETYPE = ARMv8
```

* `rpg_quadrotor_control` may record the running states of mpc by using `rosbag`.

* From LeakyCauldron: Real frequency of simulation is 200 Hz (5 times), but our required frequency is 500 HZ (25 times). Another bug is that we set the computational latency to 0 instead of 30ms for our on-board resources.

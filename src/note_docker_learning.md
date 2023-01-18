Note for an SB to build my own Dockerfile for Jetson, and test the container on my x86_64 machine. (Ref: https://github.com/NVIDIA/nvidia-docker/wiki/NVIDIA-Container-Runtime-on-Jetson)



# Hello-world!
For the ease of sending build context to Docker daemon, please move the Dockerfile to an empty dir and then build it.
```sh
cd ~ && git clone https://gitlab.kitware.com/cmake/cmake.git && cd cmake && git checkout tags/v3.22.1 && cd .. && docker build --network host -t jetson/nvidia_ros_melodic_cuda11-4-2_cudnn8:v1 . && rm -rf cmake

xhost +

docker run --runtime nvidia -it --rm --network host -v /tmp/.X11-unix:/tmp/.X11-unix --name test_jetson dustynv/ros:noetic-pytorch-l4t-r32.6.1  /bin/bash

docker run --runtime nvidia -it --rm --network host -v /tmp/.X11-unix:/tmp/.X11-unix --name test_jetson nvcr.io/nvidia/l4t-base:r32.6.1 /bin/bash


docker run -it --privileged --net=host --ipc=host --device=/dev/dri:/dev/dri -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY -e ROS_IP=127.0.0.1 --gpus all --name test_jetson dustynv/ros:noetic-pytorch-l4t-r32.6.1 /bin/bash
```

# Useful commands
```sh
docker exec -it test_jetson /bin/bash
docker tag [IMAGE ID] [REPOSITORY]:[TAG]

# Detach and Reload:
ctrl + pq
docker attach test_jetson

# Delete images
docker rmi <your-image-id>
docker rmi $(docker images -q)

# Delete containers
docker ps -a
docker container prune

# To my Jetson
ssh -p 22 nvidia@172.16.13.99
```
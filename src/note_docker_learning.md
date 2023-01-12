Note for an SB to build my own Dockerfile for Jetson, and test the container on my x86_64 machine. (Ref: https://github.com/NVIDIA/nvidia-docker/wiki/NVIDIA-Container-Runtime-on-Jetson)


# Tips of designing Dockerfile for Jetson
1. todo

# Enabling Jetson Containers on an x86 workstation (using qemu)
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


# Hello-world!
For the ease of sending build context to Docker daemon, please move the Dockerfile to an empty dir and then build it.
```sh
cd ~ && git clone https://gitlab.kitware.com/cmake/cmake.git && cd cmake && git checkout tags/v3.22.1 && cd .. && docker build --network host -t jetson/nvidia_ros_melodic_cuda11-4-2_cudnn8:v1 . && rm -rf cmake

docker run xxx

xhost +

sudo docker run --network host -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix nvcr.io/nvidia/l4t-base:r32.3.1 /bin/bash
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
```
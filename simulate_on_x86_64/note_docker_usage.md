Note for an SB to build my own Dockerfile for Jetson, and test the container on my x86_64 machine. (Ref: https://github.com/NVIDIA/nvidia-docker/wiki/NVIDIA-Container-Runtime-on-Jetson)



# Docker buld!
For the ease of sending build context to Docker daemon, please move the Dockerfile to an empty dir and then build it.
```sh
xhost +

docker run --runtime nvidia -it --network host -v /tmp/.X11-unix:/tmp/.X11-unix --name xxx xxx/xxx:xxx  /bin/bash
```

# Useful commands
```sh
# If meet an image with name as <none>
docker tag [IMAGE ID] [REPOSITORY]:[TAG]

# Containers: run, detach and Reload:
docker exec -it xxx /bin/bash
ctrl + pq
docker attach xxx

# Delete images
docker rmi <your-image-id>
docker rmi $(docker images -q)

# Delete containers
docker ps -a
docker container prune

# To my Jetson
ssh -p 22 nvidia@172.16.13.99
```
Note for an SB to build my own Dockerfile for Jetson, and test the container on my x86_64 machine. (Ref: https://github.com/NVIDIA/nvidia-docker/wiki/NVIDIA-Container-Runtime-on-Jetson)



# Image
There are mainly 3 ways to build images.
```sh
# Download from Dockerhub
docker pull <repository>:<tag>

# Build from a Dockerfile
docker build .

# Load From a saved image 
docker load < <image-name>.tar
```

Save an image
```sh
docker save > <image-name>.tar <repository>:<tag>
```

If meet an image with name as [none]

```sh
docker tag [IMAGE ID] [REPOSITORY]:[TAG]
```
  
# Container
Build a container froman image
```sh
xhost +

docker run --runtime nvidia -it --network host -v /tmp/.X11-unix:/tmp/.X11-unix --name <your-preferred-name> <repository>:<tag>  /bin/bash
```
run, detach and Reload:
```sh
docker exec -it xxx /bin/bash
ctrl + pq
docker attach xxx
```
  
# Other Useful commands
```sh
# Delete images
docker rmi <your-image-id>
docker rmi $(docker images -q)

# Delete containers
docker ps -a
docker container prune

# To my Jetson
ssh -p 22 nvidia@172.16.13.99
```

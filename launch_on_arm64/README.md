
# THIS IS USED AS ARM64 like nx2 tx

## Files

### Scripts/

- agile-ros.dockerfile : dockerfile used to build docker image
- make-agile-docker-images.sh : Shell script to build the ros docker,you should specify a tag version as a parameter,like `make-agile-docker-images.sh 1.0` will create a docker image called `qiyuan-agile-ros:1.0` in `docker images
- config.sh : Config file used when running the container
- run-agile-docker.sh : Used to run specified version docker image,and `-f` to force delete existing container and run a new one,like `run-agile-docker.sh 1.0 -f`
- setup-full-workspace.sh : Build from source
- setup-simple-workspace.sh : Build from precompiled resource
- entrypoint.sh : For for container's entrypoint file,all config can be found in `config.sh`

## Get ROS:Self Install

### Simple with precompiled resources[Suggest]

Use resources

REQUIRED:resources/open3d-build,resources/agile_autonomy_ws_melodic,resources/cv_bridge_ws existe

### Full with source codes

Compile from source in src/,include Open3d,cv_bridge,agile.

REQUIRED:src/open3d_src,src/agile_src,src/cv_bridge_src exist

## Get ROS:From full docker

We can load prebuilt docker image from `docker load < agile-ros.tar`.

## Run && Try

If all things have been done,we can have a try.

### 1.Modify `scripts/config.sh`

- SINGLE_NODE : Run ros locally if `true` was set
- NODE_OTHER_IP : If `SINGLE_NODE` was not `true`,this should be set with correct IP address
- MASTER_URI : If `SINGLE_NODE` was not `true`,just use this as master 
- HOST_NAME : If `SINGLE_NODE` was not `true`,
- INTERFACE : If `SINGLE_NODE` was not `true`,use this network interface to find current ip address
- RUN_WHEN_START : Set `true` will run ros'app when docker-container start to run

### 2.Run run script to start a ros container

Use `scripts/run-agile-docker.sh tag` we can start a ros container.If a cantainer with `tag` already exists,this just run it with `docker start`.

We can run this script with `-f` like `scripts/run-agile-docker.sh tag -f` to FORCE start a new container.

### 3.All in docker

If we set `RUN_WHEN_START` as not `true`,we just step into a docker bash `/var/files/scripts`.


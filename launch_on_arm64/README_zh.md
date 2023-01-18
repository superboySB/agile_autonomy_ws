# Agile-autonomy FLY

本开发验证平台依赖于现有的计算平台`Jetson Nx2 Tx`，该平台为`ARM 64`架构，运行`Ubuntu 18.04`操作系统。

为便于开发环境/运行环境快速部署迁移，使用了`docker`技术，增强了该平台的便捷性与适配性。


## 1 / 项目结构

项目文件结构如下：

```shell
Agile-project/
    |- scripts/
        |- config.sh
        |- entrypoint.sh
        |- make-agile-docker-images.sh
        |- run-agile-docker.sh
        |- setup-full-workspace.sh
    |- workspace/
        |- agile_autonomy_ws/
            |- catkin_aa/
                |- devel/
                |- src/
                |- build/
        |- cv_bridge_ws/
                |- devel/
                |- src/
                |- build/
        |- open3d/
            |- build/
            |- open3d_src/
    |- src/
        |- agile_src/
        |- cv_bridge_src/
        |- open3d_src/
```

本项目中的所有文件会自动挂载到运行容器的`/var/files`目录中，因此通过外界修改的代码会实时反馈到容器中。

### 1.1 / 文件介绍 

```
scripts/
```

**scripts/config.sh** 

用于配置若干信息，方便

- `SINGLE_NODE` ： 用于该容器运行场景为单机（true)或者多机（其他内容）
- `NODE_OTHER_IP` : 若在多机场景下，需要增加其他计算机的路由的IP地址，需要修改此项目
- `INTERFACE` : 在多机多网卡情况下指定绑定本机IP地址的网卡，也可强制修改下面`ROS_IP`内容，但不推荐
- `DOCKER*` ： 与本地docker环境相关，一般不需要修改

**scripts/entrypoint.sh**

此脚本为容器运行时默认启动脚本，用于根据配置文件（config.sh）初始化若干环境变量

**scripts/agile-ros.dockerfile**

此文件用于创建docker镜像的dockerfile文件

**scripts/make-agile-docker-image.sh**

此脚本用于根据根据上面文件创建镜像。具体方法如下：

```shell
./make-agile-docker-images.sh [tag-value]
```

默认情况下会生成如 `qiyuan-agile-ros:tag-value`的docker镜像，其中 `qiyuan-agile-ros` 可在 [`scripts/config.sh`](./scripts/config.sh) 中配置，相应变量名称为 `DOCKER_IMAGE_NAME`。`tag-value` 的默认值在配置中为 `0.0.0`，也可在命令中指定。


运行结束后可使用 `docker images` 查看结果情况。

**scripts/run-agile-docker.sh**

此脚本用于启动一个agile容器，具体使用如下：

```shell
./run-agile-docker.sh [tag-value][-f]
```

`tag-value` 与[make-agile-docker-image.sh](#11--文件介绍)中类似， 跟本地存放的镜像有关，若不存在则会提示已存在的容器。`-f`用于删除已创建容器（若存在的话）并开启新的容器。


## 2 / 部署

### 2.1 / 快速部署

1. 下载[`工作空间预编译项目包`](http://192.168.100.217/share/hWzeaBMK),[`docker镜像`](http://192.168.100.217/share/oDPlSblG)以及克隆[`本项目`](https://gitee.com/ai4auv/agile-ros-docker.git)
2. 使用`docker load`命令将`docker镜像`导入本地
3. 将`工作空间预编译项目包`解压到`aigle-ros-docker项目`文件夹中，如上面的文件结构中的`workspace`
4. 运行`scripts/run-agile-docker.sh`，查看输出相应的标签号，并重新运行`scripts/run-agile-docker.sh tag`命令，追加`-f`选项可以强制开启新的容器
5. 进入到该工作环境中，可直接运行现有的ros环境。

### 2.2 / 源代码部署

#### 2.2.1 / 创建agile-docker

使用 [`scripts/make-agile-docker-images.sh`](scripts/make-agile-docker-images.sh) 可以创建本地`agile-docker`,大概需要近一个小时时间，更多的取决于网速。

#### 2.2.2 / 运行agile-ros容器

使用 [`scripts/run-agile-docker.sh`](scripts/run-agile-docker.sh) 可开启一个容器，并进入该容器中。

#### 2.2.3 / 编译

将[src.7z](http://192.168.100.217/share/SwIv2Mjr)下载并解压到`/var/files`中（如[项目结构](#1--项目结构)类似)，运行 [`scripts/setup-full-workspace.sh`](scripts/setup-full-workspace.sh) 会依次编译`open3d`、`cv_bridge`与`agile_autonomy`项目。大概需要近两个小时左右。

## 3 / 运行与调试

pass
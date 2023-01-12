FROM nvcr.io/nvidia/l4t-base:r32.3.1

LABEL Zipeng Dai <daizipeng@bit.edu.cn>
LABEL Description="ROS-Melodic-Desktop with CUDA 11.4.2 and cuDNN 8 support (Jetson)" Vendor="TurluCode" Version="1.0"
LABEL com.turlucode.ros.version="melodic"

# Install packages without prompting the user to answer any questions
ENV DEBIAN_FRONTEND noninteractive 

# Install packages
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y \
build-essential \
curl \
dbus-x11 \
gedit \
git \
gdb \
gfortran \
htop \
hdf5-tools \
locales \
libhdf5-serial-dev \
lsb-release \
libatlas-base-dev \
libssl-dev \
libhdf5-dev \
libxkbfile1 \
libffi-dev \
mesa-utils \
nano \
python3-pip \
python3-dev \
subversion \
software-properties-common \
terminator \
vim \
valgrind \
wget \
xterm  && \
sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

# Install cmake 3.22.1 (my network is a shit, thus use COPY instead of git clone)
# RUN git clone https://gitlab.kitware.com/cmake/cmake.git
COPY cmake /cmake
RUN cd cmake && ./bootstrap --parallel=8 && make -j8 && make install && \
cd .. && rm -rf cmake

## Install new paramiko (solves ssh issues)
# RUN sudo apt-add-repository universe
# RUN sudo apt-get update && sudo apt-get install -y python-pip python build-essential libhdf5-dev libffi-dev && sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*
# RUN sudo pip install cpython h5py
# RUN /usr/bin/yes | pip install --upgrade "pip < 21.0" -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
# RUN /usr/bin/yes | pip install --upgrade virtualenv -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
# RUN /usr/bin/yes | pip install --upgrade paramiko -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
# RUN /usr/bin/yes | pip install --ignore-installed --upgrade -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com numpy protobuf

# Locale
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

# # Install proxychains
# RUN cd ~/ && git clone https://github.com/rofl0r/proxychains-ng.git && \
#     cd proxychains-ng && ./configure --prefix=/usr --sysconfdir=/etc && \
#     make && sudo make install && sudo cp src/proxychains.conf /etc/proxychains.conf && \
#     sudo sed -i 's/socks4/socks5/' /etc/proxychains.conf && sudo sed -i 's/9050/1080/' /etc/proxychains.conf && \
#     rm -rf ~/proxychains-ng

# # Install tmux 3.2
# RUN sudo apt-get update && sudo apt-get install -y automake autoconf pkg-config libevent-dev libncurses5-dev bison && \
#     sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*
# RUN cd ~/ && git clone https://github.com/tmux/tmux.git && \
#     cd tmux && git checkout tags/3.2 && ls -la && sh autogen.sh && ./configure && make -j8 && sudo make install && \
#     rm -rf ~/tmux


# **************************
# *      ROS Melodic       *
# **************************

## Install ROS
RUN sudo sh -c 'echo "deb https://repo.huaweicloud.com/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
# set timezone before installing ros packages
#RUN sudo touch /etc/timezone && sudo ln -snf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && echo $CONTAINER_TIMEZONE | sudo tee -a /etc/timezone
RUN sudo ln -snf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && echo $CONTAINER_TIMEZONE | sudo tee -a /etc/timezone
RUN sudo apt-get update && sudo apt-get install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
    tzdata \
    libpcap-dev \
    libopenblas-dev \
    gstreamer1.0-tools libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-good1.0-dev \
    ros-melodic-desktop-full python-rosinstall python-rosinstall-generator python-wstool build-essential python-rosdep \
    ros-melodic-socketcan-bridge \
    ros-melodic-geodesy && \
    sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

## Configure ROS
RUN echo "151.101.192.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts && sudo rosdep init # && rosdep update
RUN echo "source /opt/ros/melodic/setup.bash" | sudo tee -a ~/.bashrc
RUN echo "export ROSLAUNCH_SSH_UNKNOWN=1" | sudo tee -a ~/.bashrc
RUN echo "export PATH=~/.local/bin:$PATH" | sudo tee -a ~/.bashrc
# RUN echo "source /opt/ros/melodic/setup.zsh" | sudo tee -a ~/.zshrc
# RUN echo "export ROSLAUNCH_SSH_UNKNOWN=1" | sudo tee -a ~/.zshrc
# RUN echo "export PATH=~/.local/bin:$PATH" | sudo tee -a ~/.zshrc

# ****************************************
# *         ROS Melodic Installed        *
# ****************************************


# **********************************************
# *           CUDA 11.4.2 + CUDNN 8            *
# **********************************************
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/sbsa/cuda-ubuntu1804.pin
RUN sudo mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600
RUN wget https://developer.download.nvidia.com/compute/cuda/11.4.2/local_installers/cuda-repo-ubuntu1804-11-4-local_11.4.2-470.57.02-1_arm64.deb
RUN sudo dpkg -i cuda-repo-ubuntu1804-11-4-local_11.4.2-470.57.02-1_arm64.deb
RUN sudo apt-key add /var/cuda-repo-ubuntu1804-11-4-local/7fa2af80.pub
RUN sudo apt-get update && sudo apt-get -y install cuda

RUN echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-11.4/lib64" | sudo tee -a ~/.bashrc
RUN echo "PATH=$PATH:/usr/local/cuda-11.4/bin" | sudo tee -a ~/.bashrc
RUN echo "CUDA_HOME=$CUDA_HOME:/usr/local/cuda-11.4" | sudo tee -a ~/.bashrc
RUN source ~/.bashrc

# ## CUDA Base-packages
# RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends gnupg2 curl ca-certificates && \
#     curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | sudo apt-key add - && \
#     echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" | sudo tee -a /etc/apt/sources.list.d/cuda.list && \
#     echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" | sudo tee -a /etc/apt/sources.list.d/nvidia-ml.list && \
#     sudo rm -rf /var/lib/apt/lists/*

# ENV CUDA_VERSION 11.4.2
# ENV NV_CUDA_CUDART_VERSION 11.4.108-1
# ENV NV_CUDA_COMPAT_PACKAGE cuda-compat-11-4
# LABEL com.turlucode.ros.cuda="${CUDA_VERSION}"

# ## For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
# RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A4B469963BF863CC && \
#     sudo apt-get update && sudo apt-get install -y --no-install-recommends \
#     cuda-cudart-11-4=${NV_CUDA_CUDART_VERSION} \
#     ${NV_CUDA_COMPAT_PACKAGE} \
#     && sudo ln -s cuda-11.4 /usr/local/cuda && \
#     sudo rm -rf /var/lib/apt/lists/*

# ## Required for nvidia-docker v1
# RUN echo "/usr/local/nvidia/lib" | sudo tee -a /etc/ld.so.conf.d/nvidia.conf \
#     && echo "/usr/local/nvidia/lib64" | sudo tee -a /etc/ld.so.conf.d/nvidia.conf

# ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
# ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

# ENV NVIDIA_VISIBLE_DEVICES all
# ENV NVIDIA_DRIVER_CAPABILITIES all
# ENV NVIDIA_REQUIRE_CUDA "cuda>=11.4 brand=tesla,driver>=418,driver<419 brand=tesla,driver>=440,driver<441 driver>=450"

# ## CUDA Runtime-packages
# ENV NV_CUDA_LIB_VERSION 11.4.2-1
# ENV NV_LIBNPP_VERSION 11.4.0.110-1
# ENV NV_LIBNPP_PACKAGE libnpp-11-4=${NV_LIBNPP_VERSION}
# ENV NV_NVTX_VERSION 11.4.120-1
# ENV NV_LIBCUSPARSE_VERSION 11.6.0.120-1

# ENV NV_LIBCUBLAS_PACKAGE_NAME libcublas-11-4
# ENV NV_LIBCUBLAS_VERSION 11.6.1.51-1
# ENV NV_LIBCUBLAS_PACKAGE ${NV_LIBCUBLAS_PACKAGE_NAME}=${NV_LIBCUBLAS_VERSION}

# ENV NV_LIBNCCL_PACKAGE_NAME libnccl2
# ENV NV_LIBNCCL_PACKAGE_VERSION 2.11.4-1
# ENV NCCL_VERSION 2.11.4-1
# ENV NV_LIBNCCL_PACKAGE ${NV_LIBNCCL_PACKAGE_NAME}=${NV_LIBNCCL_PACKAGE_VERSION}+cuda11.4

# RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
#     cuda-libraries-11-4=${NV_CUDA_LIB_VERSION} \
#     ${NV_LIBNPP_PACKAGE} \
#     cuda-nvtx-11-4=${NV_NVTX_VERSION} \
#     libcusparse-11-4=${NV_LIBCUSPARSE_VERSION} \
#     ${NV_LIBCUBLAS_PACKAGE} \
#     ${NV_LIBNCCL_PACKAGE} \
#     && sudo rm -rf /var/lib/apt/lists/*

# ## Keep apt from auto upgrading the cublas and nccl packages. See https://gitlab.com/nvidia/container-images/cuda/-/issues/88
# RUN sudo apt-mark hold ${NV_LIBCUBLAS_PACKAGE_NAME} ${NV_LIBNCCL_PACKAGE_NAME}

# ## CUDA Devel-packages
# ENV NV_CUDA_CUDART_DEV_VERSION 11.4.108-1
# ENV NV_NVML_DEV_VERSION 11.4.120-1
# ENV NV_LIBNPP_DEV_VERSION 11.4.0.110-1
# ENV NV_LIBNPP_DEV_PACKAGE libnpp-dev-11-4=${NV_LIBNPP_DEV_VERSION}
# ENV NV_LIBCUSPARSE_DEV_VERSION 11.6.0.120-1

# ENV NV_LIBCUBLAS_DEV_VERSION 11.6.1.51-1
# ENV NV_LIBCUBLAS_DEV_PACKAGE_NAME libcublas-dev-11-4
# ENV NV_LIBCUBLAS_DEV_PACKAGE ${NV_LIBCUBLAS_DEV_PACKAGE_NAME}=${NV_LIBCUBLAS_DEV_VERSION}

# ENV NV_LIBNCCL_DEV_PACKAGE_NAME libnccl-dev
# ENV NV_LIBNCCL_DEV_PACKAGE_VERSION 2.11.4-1
# ENV NCCL_VERSION 2.11.4-1
# ENV NV_LIBNCCL_DEV_PACKAGE ${NV_LIBNCCL_DEV_PACKAGE_NAME}=${NV_LIBNCCL_DEV_PACKAGE_VERSION}+cuda11.4

# RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
#     cuda-cudart-dev-11-4=${NV_CUDA_CUDART_DEV_VERSION} \
#     cuda-command-line-tools-11-4=${NV_CUDA_LIB_VERSION} \
#     cuda-minimal-build-11-4=${NV_CUDA_LIB_VERSION} \
#     cuda-libraries-dev-11-4=${NV_CUDA_LIB_VERSION} \
#     cuda-nvml-dev-11-4=${NV_NVML_DEV_VERSION} \
#     ${NV_LIBNPP_DEV_PACKAGE} \
#     libcusparse-dev-11-4=${NV_LIBCUSPARSE_DEV_VERSION} \
#     ${NV_LIBCUBLAS_DEV_PACKAGE} \
#     ${NV_LIBNCCL_DEV_PACKAGE} \
#     && sudo rm -rf /var/lib/apt/lists/*


# ## Keep apt from auto upgrading the cublas and nccl packages. See https://gitlab.com/nvidia/container-images/cuda/-/issues/88
# RUN sudo apt-mark hold ${NV_LIBCUBLAS_DEV_PACKAGE_NAME} ${NV_LIBNCCL_DEV_PACKAGE_NAME}

# ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs

## CUDNN Runtime-packages
ENV NV_CUDNN_VERSION 8.2.4.15
ENV NV_CUDNN_PACKAGE "libcudnn8=$NV_CUDNN_VERSION-1+cuda11.4"
LABEL com.turlucode.ros.cudnn="${NV_CUDNN_VERSION}"

RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    ${NV_CUDNN_PACKAGE} && \
    sudo rm -rf /var/lib/apt/lists/*

## CUDNN Devel-packages
ENV NV_CUDNN_PACKAGE_DEV "libcudnn8-dev=$NV_CUDNN_VERSION-1+cuda11.4"

RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    ${NV_CUDNN_PACKAGE} \
    ${NV_CUDNN_PACKAGE_DEV} && \
    sudo rm -rf /var/lib/apt/lists/*

RUN sudo apt-mark hold libcudnn8
# ****************************************************
# *         CUDA 11.4.2 + CUDNN 8 Installed          *
# ****************************************************


## Create the user
ARG USERNAME=qiyuan
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    apt-get update && \
    apt-get install -y sudo apt-utils \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME && \
    sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*
    # ********************************************************
    # * Anything else you want to do like clean up goes here *
    # ********************************************************
    # [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME






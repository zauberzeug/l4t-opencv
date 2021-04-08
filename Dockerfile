FROM nvcr.io/nvidia/l4t-base:r32.4.4

# Source: https://github.com/dusty-nv/jetson-containers/blob/master/Dockerfile.ml 
ENV DEBIAN_FRONTEND=noninteractive
ENV CUDA_HOME="/usr/local/cuda"
ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"
ENV LLVM_CONFIG="/usr/bin/llvm-config-9"

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#
# apt packages
#
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3-pip \
    python3-distutils \
    python3-dev \
    python3-setuptools \
    python3-matplotlib \
    build-essential \
    gfortran \
    git \
    cmake \
    curl \
    unzip \
    vim \
    gnupg \
    libopencv-dev \
    libopenblas-dev \
    liblapack-dev \
    libblas-dev \
    libhdf5-serial-dev \
    hdf5-tools \
    libhdf5-dev \
    zlib1g-dev \
    zip \
    pkg-config \
    libavcodec-dev \ 
    libavformat-dev \ 
    libswscale-dev \
    libtbb2 \
    libtbb-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libv4l-dev \
    v4l-utils \
    qv4l2 \
    v4l2ucp \
    libdc1394-22-dev \

    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \

    libgtk2.0-dev \
    libjpeg8-dev \
    libopenmpi2 \
    openmpi-bin \
    openmpi-common \
    protobuf-compiler \
    libprotoc-dev \
    llvm-9 \
    llvm-9-dev \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN ln -sf /usr/bin/python3.6 /usr/bin/python3 && ln -sf /usr/bin/python3.6 /usr/bin/python

#Remove existing opencv
RUN apt-get -y purge *libopencv*

RUN apt -y autoremove

RUN python3 -m pip install numpy

ARG OPENCV_VERSION
ARG MAKEFLAGS

WORKDIR /root

RUN curl -L https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip -o opencv-${OPENCV_VERSION}.zip && \
    curl -L https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip -o opencv_contrib-${OPENCV_VERSION}.zip && \
    unzip opencv-${OPENCV_VERSION}.zip && \
    unzip opencv_contrib-${OPENCV_VERSION}.zip
       
RUN cd opencv-${OPENCV_VERSION}/ && mkdir build && cd build && \
    cmake -D WITH_CUDA=ON -D WITH_CUDNN=ON -D CUDA_ARCH_BIN="5.3,6.2,7.2" -D CUDA_ARCH_PTX="" -D OPENCV_GENERATE_PKGCONFIG=ON -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-${OPENCV_VERSION}/modules -D WITH_GSTREAMER=ON -D WITH_LIBV4L=ON -D BUILD_opencv_python2=ON -D BUILD_opencv_python3=ON -D BUILD_TESTS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_EXAMPLES=OFF -D CUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-10.2 -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local .. && \
    make $MAKEFLAGS && make install

# cleanup build files to reduce container size
RUN rm -r opencv*

RUN bash



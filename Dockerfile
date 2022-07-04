FROM nvcr.io/nvidia/l4t-base:r32.6.1 as builder

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
    && apt-get -y purge *libopencv* \
    && apt -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#Python 3.10
RUN apt-get update && apt-get install software-properties-common -y && add-apt-repository ppa:deadsnakes/ppa
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y python3.9 python3.9-dev python3.9-distutils
ENV PYTHONPATH "${PYTHONPATH}:/usr/local/lib/python3.9/dist-packages/"

RUN rm /usr/bin/python3 && ln -s /usr/bin/python3.9 /usr/bin/python3
RUN python3 --version
RUN whereis python3
RUN python3 -m pip install --upgrade pip setuptools cython

RUN pip3 install --upgrade cmake
RUN pip3 install --no-cache-dir wheel
RUN pip3 install --no-cache-dir pycuda

RUN apt-get update && \
        DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC \
        apt-get install -y --no-install-recommends \
        libjpeg8-dev zlib1g-dev \
        pkg-config \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean


RUN pip3 uninstall numpy -y
RUN pip3 install numpy==1.22.4
RUN python3 -c "import numpy; print(numpy.version.version)"

ARG OPENCV_VERSION
ARG MAKEFLAGS

WORKDIR /root

RUN curl -L https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip -o opencv-${OPENCV_VERSION}.zip && \
    curl -L https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip -o opencv_contrib-${OPENCV_VERSION}.zip && \
    unzip opencv-${OPENCV_VERSION}.zip && \
    unzip opencv_contrib-${OPENCV_VERSION}.zip

WORKDIR /root/opencv-${OPENCV_VERSION}/build

RUN python3 -c "import numpy; print(numpy.version.version)"

RUN cmake -D WITH_VTK=OFF -D BUILD_opencv_viz=OFF -D OPENCV_PYTHON3_INSTALL_PATH=/usr/local/lib/python3.9/dist-packages -DPYTHON_DEFAULT_EXECUTABLE=$(which python3) -DWITH_QT=OFF -DWITH_GTK=OFF -D WITH_CUDA=ON -D WITH_CUDNN=ON -D CUDA_ARCH_BIN="5.3,6.2,7.2" -D CUDA_ARCH_PTX="" -D OPENCV_GENERATE_PKGCONFIG=ON -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-${OPENCV_VERSION}/modules -D WITH_GSTREAMER=ON -D WITH_LIBV4L=ON -D BUILD_opencv_python2=OFF -D BUILD_opencv_python3=ON -D BUILD_TESTS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_EXAMPLES=OFF -D CUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-10.2 -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local/opencv ..

RUN make $MAKEFLAGS 

RUN make install

# CMD bash

FROM nvcr.io/nvidia/l4t-base:r32.6.1

#Python 3.9
RUN apt-get update && apt-get install software-properties-common -y && add-apt-repository ppa:deadsnakes/ppa
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y python3.9 python3.9-dev python3.9-distutils
ENV PYTHONPATH "${PYTHONPATH}:/usr/local/lib/python3.9/dist-packages/"

RUN rm /usr/bin/python3 && ln -s /usr/bin/python3.9 /usr/bin/python3
RUN python3 --version
RUN whereis python3
RUN apt-get install python3-pip -y
RUN python3 -m pip install --upgrade pip setuptools cython

RUN pip3 install --upgrade cmake
RUN pip3 install --no-cache-dir wheel
RUN pip3 install --no-cache-dir pycuda

RUN apt-get update && \
        DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC \
        apt-get install -y --no-install-recommends \
        libjpeg8-dev zlib1g-dev \
        pkg-config \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

COPY --from=builder /usr/local/opencv /usr/local
COPY --from=builder /usr/local/lib/python3.9/dist-packages /usr/local/lib/python3.9/dist-packages

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-setuptools \
    python3-h5py \
    && apt -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install cython numpy
# ENV PYTHONPATH "${PYTHONPATH}:/usr/local/lib/python3.9/dist-packages/"

WORKDIR /root


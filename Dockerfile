## ******************************************************************************
## This source code is licensed under the MIT license found in the
## LICENSE file in the root directory of this source tree.
##
## Copyright (c) 2024 Georgia Institute of Technology
## ******************************************************************************

## Use Ubuntu
FROM ubuntu:22.04
LABEL maintainer="Will Won <william.won@gatech.edu>"
LABEL maintainer="Jinsun Yoo <jinsun@gatech.edu>"

### ================== System Setups ======================
## Install System Dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt -y update && apt -y install \
    coreutils wget vim git \
    gcc g++ clang-format \
    make cmake \
    libboost-dev libboost-program-options-dev \
    openmpi-bin openmpi-doc libopenmpi-dev \
    python3.11 python3-pip python3-venv \
    graphviz

## Create Python venv: Required for Python 3.11
RUN python3 -m venv /opt/venv/astra-sim
ENV PATH="/opt/venv/astra-sim/bin:$PATH"
RUN pip3 install --upgrade pip

# STG dependencies
RUN pip3 install numpy sympy graphviz pandas
### ======================================================


### ====== Abseil Installation: Protobuf Dependency ======
## Download Abseil 20240722.0 (Latest LTS as of 10/31/2024)
ARG ABSL_VER=20240722.0

# Download source
WORKDIR /opt
RUN wget https://github.com/abseil/abseil-cpp/releases/download/${ABSL_VER}/abseil-cpp-${ABSL_VER}.tar.gz \
    && tar -xf abseil-cpp-${ABSL_VER}.tar.gz \
    && rm abseil-cpp-${ABSL_VER}.tar.gz

## Compile Abseil
WORKDIR /opt/abseil-cpp-${ABSL_VER}/build
RUN cmake .. \
    -DCMAKE_CXX_STANDARD=14 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="/opt/abseil-cpp-${ABSL_VER}/install" \
 && cmake --build . --target install --config Release --parallel $(nproc)
ENV absl_DIR="/opt/abseil-cpp-${ABSL_VER}/install"
### ======================================================


### ============= Protobuf Installation ==================
## Download Protobuf 29.0 (=v5.29.0, latest stable version as of Feb/01/2025)
ARG PROTOBUF_VER=29.0

# Download source
WORKDIR /opt
RUN wget https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VER}/protobuf-${PROTOBUF_VER}.tar.gz \
    && tar -xf protobuf-${PROTOBUF_VER}.tar.gz \
    && rm protobuf-${PROTOBUF_VER}.tar.gz

## Compile Protobuf
WORKDIR /opt/protobuf-${PROTOBUF_VER}/build
RUN cmake .. \
    -DCMAKE_CXX_STANDARD=14 \
    -DCMAKE_BUILD_TYPE=Release \
    -Dprotobuf_BUILD_TESTS=OFF \
    -Dprotobuf_ABSL_PROVIDER=package \
    -DCMAKE_INSTALL_PREFIX="/opt/protobuf-${PROTOBUF_VER}/install" \
 && cmake --build . --target install --config Release --parallel $(nproc)
ENV PATH="/opt/protobuf-${PROTOBUF_VER}/install/bin:$PATH"
ENV protobuf_DIR="/opt/protobuf-${PROTOBUF_VER}/install"

# Also, install Python protobuf package
RUN pip3 install protobuf==5.${PROTOBUF_VER}

# Set the environment variable
ENV PROTOBUF_FROM_SOURCE=True
### ======================================================


### ================ ASTRA-sim Setup =====================
WORKDIR /app

# Clone ASTRA-sim and submodules
RUN git clone https://github.com/ChadCYB/astra-sim.git \
    && cd astra-sim \
    && git checkout ns3-test \
    && git submodule update --init --recursive

# Create Chakra symlink and install
RUN cd /app/astra-sim \
    && ln -s extern/graph_frontend/chakra chakra \
    && cd chakra \
    && pip3 install . \
    && cd /app/astra-sim

# Clone and install Param & STG
RUN cd /app/astra-sim \
    && git clone https://github.com/facebookresearch/param.git \
    && git clone https://github.com/astra-sim/symbolic_tensor_graph.git \
    && git config --global --add safe.directory /app/param \
    && cd param/et_replay \
    && git checkout 7b19f586dd8b267333114992833a0d7e0d601630 \
    && pip3 install . \
    && cd /app

# Build analytical backend
RUN cd /app/astra-sim/build/astra_analytical \
    && ./build.sh

# Build NS3 backend
RUN cd /app/astra-sim \
    && bash build/astra_ns3/build.sh


### ================== Finalize ==========================
## Move to the application directory
WORKDIR /app/astra-sim
### ======================================================

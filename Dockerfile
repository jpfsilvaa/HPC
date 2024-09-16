FROM ubuntu:22.04 AS build

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        autotools-dev \
        ca-certificates \
        git \
        libtool \
        make \
        python3 \
        python3-pip \
        tar \
        wget && \
    rm -rf /var/lib/apt/lists/*

# GNU compiler
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        g++-12 \
        gcc-12 \
        gfortran-12 && \
    rm -rf /var/lib/apt/lists/*
RUN update-alternatives --install /usr/bin/g++ g++ $(which g++-12) 30 && \
    update-alternatives --install /usr/bin/gcc gcc $(which gcc-12) 30 && \
    update-alternatives --install /usr/bin/gcov gcov $(which gcov-12) 30 && \
    update-alternatives --install /usr/bin/gfortran gfortran $(which gfortran-12) 30

# CMake version 3.25.1
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        make \
        wget && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://github.com/Kitware/CMake/releases/download/v3.25.1/cmake-3.25.1-linux-x86_64.sh && \
    mkdir -p /usr/local && \
    /bin/sh /var/tmp/cmake-3.25.1-linux-x86_64.sh --prefix=/usr/local --skip-license && \
    rm -rf /var/tmp/cmake-3.25.1-linux-x86_64.sh
ENV PATH=/usr/local/bin:$PATH

# Mellanox OFED version 5.8-3.0.7.0
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        wget && \
    rm -rf /var/lib/apt/lists/*
RUN wget -qO - https://www.mellanox.com/downloads/ofed/RPM-GPG-KEY-Mellanox | apt-key add - && \
    mkdir -p /etc/apt/sources.list.d && wget -q -nc --no-check-certificate -P /etc/apt/sources.list.d https://linux.mellanox.com/public/repo/mlnx_ofed/5.8-3.0.7.0/ubuntu22.04/mellanox_mlnx_ofed.list && \
    apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ibverbs-providers \
        ibverbs-utils \
        libibmad-dev \
        libibmad5 \
        libibumad-dev \
        libibumad3 \
        libibverbs-dev \
        libibverbs1 \
        librdmacm-dev \
        librdmacm1 && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/openucx/ucx/releases/download/v1.14.0/ucx-1.14.0.tar.gz && \
    tar -xzf ucx-1.14.0.tar.gz && \
    cd ucx-1.14.0 && \
    ./configure --prefix=/usr/local/ucx && \
    make && \
    make install

# OpenMPI version 5.0.5
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        bzip2 \
        file \
        hwloc \
        libnuma-dev \
        make \
        openssh-client \
        perl \
        tar \
        wget && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://www.open-mpi.org/software/ompi/v5.0/downloads/openmpi-5.0.5.tar.bz2 && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/openmpi-5.0.5.tar.bz2 -C /var/tmp -j && \
    cd /var/tmp/openmpi-5.0.5 &&   ./configure --prefix=/usr/local/openmpi --disable-getpwuid --enable-orterun-prefix-by-default --with-ucx=/usr/local/ucx --with-verbs --without-cuda && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    rm -rf /var/tmp/openmpi-5.0.5 /var/tmp/openmpi-5.0.5.tar.bz2
ENV LD_LIBRARY_PATH=/usr/local/openmpi/lib:$LD_LIBRARY_PATH \
    PATH=/usr/local/openmpi/bin:$PATH

RUN wget http://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-5.6.2.tar.gz && \
    tar zxvf ./osu-micro-benchmarks-5.6.2.tar.gz && \
    cd osu-micro-benchmarks-5.6.2/ && \
    ./configure CC=/usr/local/openmpi/bin/mpicc CXX=/usr/local/openmpi/bin/mpicxx --prefix=/usr/local/osu && \
    make && \
    make install

ENV LD_LIBRARY_PATH=/usr/local/openmpi/lib:$LD_LIBRARY_PATH \
    PATH=/usr/local/openmpi/bin:$PATH



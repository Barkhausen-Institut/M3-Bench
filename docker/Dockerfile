FROM ubuntu:22.04
LABEL description="Build environment for M³'s RTAS'24 benchmarks."

# install dependencies
RUN set -x \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
       bc \
       bison \
       build-essential \
       cpio \
       clang \
       curl \
       file \
       flex \
       gawk \
       git \
       iproute2 \
       libcurl4-openssl-dev \
       libelf-dev \
       libfontconfig1-dev \
       libfreetype6-dev \
       libfribidi-dev \
       libgmp-dev \
       libgoogle-perftools-dev \
       libharfbuzz-dev \
       libjpeg-dev \
       libmpc-dev \
       libmpfr-dev \
       libncurses-dev \
       libpng-dev \
       libprotobuf-dev=3.12.* \
       libssl-dev \
       libtiff5-dev \
       libtinfo5 \
       libxml2-utils \
       m4 \
       ninja-build \
       openssh-client \
       openssh-server \
       pkg-config \
       protobuf-compiler=3.12.* \
       python3=3.10.* \
       python3-dev=3.10.* \
       python-is-python3 \
       python3-pyelftools \
       python3-serial \
       r-base \
       rsync \
       scons=4.0.* \
       sudo \
       telnet \
       texinfo \
       texlive-extra-utils \
       unzip \
       vim \
       wget \
       zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y

# setup local ssh
RUN mkdir -p $HOME/.ssh \
    && ssh-keygen -t ed25519 -N "" -C "m3-rtas24" -f $HOME/.ssh/id_ed25519 \
    && cat $HOME/.ssh/id_ed25519.pub >> $HOME/.ssh/authorized_keys \
    && service ssh start \
    && ssh-keyscan -H localhost >> $HOME/.ssh/known_hosts

# install R packages
RUN echo "install.packages('tidyverse')" | R --no-save
RUN echo "install.packages('gridExtra')" | R --no-save

# allow to use git repository cloned on host
RUN git config --global --add safe.directory '*'

WORKDIR /m3bench

ENTRYPOINT service ssh restart && "/bin/bash"

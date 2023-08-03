FROM ubuntu:20.04 as build_dependencies-stage

RUN apt-get update \
  && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
      git \
      python3 \
      python3-pip \
      python3-distutils \
      xz-utils \
      bzip2 \
      zip \
      gpg \
      wget \
      gpgconf \
      software-properties-common \
      libsigsegv2 \
      libsigsegv-dev \
      pkg-config \
      zlib1g \
      zlib1g-dev \
      m4 \
  && rm -rf /var/lib/apt/lists/*

# Cmake ppa
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
RUN echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main' | tee /etc/apt/sources.list.d/kitware.list >/dev/null

# gcc ppa
RUN add-apt-repository ppa:ubuntu-toolchain-r/test

RUN apt-get update \
  && apt-get install -y \
     gcc-11 \
     g++-11 \
     gfortran-11 \
     cmake-data=3.21.3-0kitware1ubuntu20.04.1 \
     cmake=3.21.3-0kitware1ubuntu20.04.1 \
     pkg-config \
     libncurses5-dev \
     m4 \
     perl \
  && rm -rf /var/lib/apt/lists/*
RUN pip install clingo
# Now we install spack and find compilers/externals
RUN mkdir -p /opt/ && cd /opt/ && git clone --depth 1 --branch "v0.20.1" https://github.com/spack/spack.git
RUN . /opt/spack/share/spack/setup-env.sh && spack compiler find
RUN . /opt/spack/share/spack/setup-env.sh && spack external find --not-buildable && spack external list
RUN mkdir -p /opt/spack-environment
ADD ./spack-depends-serial.yml /opt/spack-environment/spack-serial.yaml
RUN mv /opt/spack-environment/spack-serial.yaml /opt/spack-environment/spack.yaml
# create pre_nimble environment from spack.yaml and concretize
RUN cd /opt/spack-environment \
  && . /opt/spack/share/spack/setup-env.sh && spack env create pre_nimble /opt/spack-environment/spack.yaml\
  && spack env activate pre_nimble && spack concretize && spack env deactivate
# make nimble env from lock
RUN . /opt/spack/share/spack/setup-env.sh && spack env create nimble /opt/spack/var/spack/environments/pre_nimble/spack.lock
# activate nimble env and install
RUN . /opt/spack/share/spack/setup-env.sh && spack env activate nimble && spack install --fail-fast && spack gc -y

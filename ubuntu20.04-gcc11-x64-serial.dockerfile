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

## Create all serial spack environments
## Make serial nimble env
RUN mkdir -p /opt/spack-nimble-env-serial
ADD ./spack-serial.yaml /opt/spack-nimble-env-serial/spack-serial.yaml
RUN mv /opt/spack-nimble-env-serial/spack-serial.yaml /opt/spack-nimble-env-serial/spack.yaml
# create pre_nimble-serial environment from spack.yaml and concretize
RUN cd /opt/spack-nimble-env-serial \
  && . /opt/spack/share/spack/setup-env.sh && spack env create pre_nimble-serial /opt/spack-nimble-env-serial/spack.yaml\
  && spack env activate pre_nimble-serial && spack concretize && spack env deactivate
# make nimble-serial env from lock
RUN . /opt/spack/share/spack/setup-env.sh && spack env create nimble-serial /opt/spack/var/spack/environments/pre_nimble-serial/spack.lock
# activate nimble-serial env and install
RUN . /opt/spack/share/spack/setup-env.sh && spack env activate nimble-serial && spack install --fail-fast && spack gc -y && spack env deactivate

## Make serial+Trilinos nimble env
RUN mkdir -p /opt/spack-nimble-env-serial-trilinos
ADD ./spack-serial-trilinos.yaml /opt/spack-nimble-env-serial-trilinos/spack-serial-trilinos.yaml
RUN mv /opt/spack-nimble-env-serial-trilinos/spack-serial-trilinos.yaml /opt/spack-nimble-env-serial-trilinos/spack.yaml
# create pre_nimble-serial-trilinos environment from spack.yaml and concretize
RUN cd /opt/spack-nimble-env-serial-trilinos \
  && . /opt/spack/share/spack/setup-env.sh && spack env create pre_nimble-serial-trilinos /opt/spack-nimble-env-serial-trilinos/spack.yaml\
  && spack env activate pre_nimble-serial-trilinos && spack concretize && spack env deactivate
# make nimble-serial-trilinos env from lock
RUN . /opt/spack/share/spack/setup-env.sh && spack env create nimble-serial-trilinos /opt/spack/var/spack/environments/pre_nimble-serial-trilinos/spack.lock
# activate nimble-serial-trilinos env and install
RUN . /opt/spack/share/spack/setup-env.sh && spack env activate nimble-serial-trilinos && spack install --fail-fast && spack gc -y && spack env deactivate

## Make serial+Kokkos nimble env
RUN mkdir -p /opt/spack-nimble-env-serial-kokkos
ADD ./spack-serial-kokkos.yaml /opt/spack-nimble-env-serial-kokkos/spack-serial-kokkos.yaml
RUN mv /opt/spack-nimble-env-serial-kokkos/spack-serial-kokkos.yaml /opt/spack-nimble-env-serial-kokkos/spack.yaml
# create pre_nimble-serial-kokkos environment from spack.yaml and concretize
RUN cd /opt/spack-nimble-env-serial-kokkos \
  && . /opt/spack/share/spack/setup-env.sh && spack env create pre_nimble-serial-kokkos /opt/spack-nimble-env-serial-kokkos/spack.yaml\
  && spack env activate pre_nimble-serial-kokkos && spack concretize && spack env deactivate
# make nimble-serial-kokkos env from lock
RUN . /opt/spack/share/spack/setup-env.sh && spack env create nimble-serial-kokkos /opt/spack/var/spack/environments/pre_nimble-serial-kokkos/spack.lock
# activate nimble-serial-kokkos env and install
RUN . /opt/spack/share/spack/setup-env.sh && spack env activate nimble-serial-kokkos && spack install --fail-fast && spack gc -y && spack env deactivate

## Make serial+Kokkos+ArborX nimble env
RUN mkdir -p /opt/spack-nimble-env-serial-kokkos-arborx
ADD ./spack-serial-kokkos-arborx.yaml /opt/spack-nimble-env-serial-kokkos-arborx/spack-serial-kokkos-arborx.yaml
RUN mv /opt/spack-nimble-env-serial-kokkos-arborx/spack-serial-kokkos-arborx.yaml /opt/spack-nimble-env-serial-kokkos-arborx/spack.yaml
# create pre_nimble-serial-kokkos-arborx environment from spack.yaml and concretize
RUN cd /opt/spack-nimble-env-serial-kokkos-arborx \
  && . /opt/spack/share/spack/setup-env.sh && spack env create pre_nimble-serial-kokkos-arborx /opt/spack-nimble-env-serial-kokkos-arborx/spack.yaml\
  && spack env activate pre_nimble-serial-kokkos-arborx && spack concretize && spack env deactivate
# make nimble-serial-kokkos-arborx env from lock
RUN . /opt/spack/share/spack/setup-env.sh && spack env create nimble-serial-kokkos-arborx /opt/spack/var/spack/environments/pre_nimble-serial-kokkos-arborx/spack.lock
# activate nimble-serial-kokkos-arborx env and install
RUN . /opt/spack/share/spack/setup-env.sh && spack env activate nimble-serial-kokkos-arborx && spack install --fail-fast && spack gc -y && spack env deactivate

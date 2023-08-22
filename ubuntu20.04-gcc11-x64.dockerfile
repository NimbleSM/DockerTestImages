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
     gcc-11=11.4.0-2ubuntu1~20.04 \
     g++-11=11.4.0-2ubuntu1~20.04 \
     gfortran-11=11.4.0-2ubuntu1~20.04 \
     cmake-data=3.26.4-0kitware1ubuntu20.04.1 \
     cmake=3.26.4-0kitware1ubuntu20.04.1 \
     pkg-config \
     libncurses5-dev \
     m4 \
     perl \
  && rm -rf /var/lib/apt/lists/*
RUN pip install clingo

# Now we install spack and find compilers/externals
RUN mkdir -p /opt/ && cd /opt/ && git clone --depth 1 --branch "v0.20.1" https://github.com/spack/spack.git

# Add current source dir into the image
COPY . /opt/src/NimbleSMBaseImage

# Apply our patch to get more up-to-date packages
RUN cd /opt/spack && git apply /opt/src/NimbleSMBaseImage/arborx_spack_package.patch

RUN . /opt/spack/share/spack/setup-env.sh && spack compiler find
RUN . /opt/spack/share/spack/setup-env.sh && spack external find --not-buildable && spack external list

### MPI ENVIRONMENTS ###
# Create all mpi spack environments

## Make mpi nimble env
RUN mkdir -p /opt/spack-nimble-env-mpi
ADD ./spack-mpi.yaml /opt/spack-nimble-env-mpi/spack-mpi.yaml
RUN mv /opt/spack-nimble-env-mpi/spack-mpi.yaml /opt/spack-nimble-env-mpi/spack.yaml
# create pre_nimble-mpi environment from spack.yaml and concretize
RUN cd /opt/spack-nimble-env-mpi \
  && . /opt/spack/share/spack/setup-env.sh && spack env create pre_nimble-mpi /opt/spack-nimble-env-mpi/spack.yaml\
  && spack env activate pre_nimble-mpi && spack concretize && spack env deactivate
# make nimble-mpi env from lock
RUN . /opt/spack/share/spack/setup-env.sh && spack env create nimble-mpi /opt/spack/var/spack/environments/pre_nimble-mpi/spack.lock
# activate nimble-mpi env and install
RUN . /opt/spack/share/spack/setup-env.sh && spack env activate nimble-mpi && spack install --fail-fast && spack gc -y && spack env deactivate


## Make mpi+Trilinos nimble env
RUN mkdir -p /opt/spack-nimble-env-mpi-trilinos
ADD ./spack-mpi-trilinos.yaml /opt/spack-nimble-env-mpi-trilinos/spack-mpi-trilinos.yaml
RUN mv /opt/spack-nimble-env-mpi-trilinos/spack-mpi-trilinos.yaml /opt/spack-nimble-env-mpi-trilinos/spack.yaml
# create pre_nimble-mpi-trilinos environment from spack.yaml and concretize
RUN cd /opt/spack-nimble-env-mpi-trilinos \
  && . /opt/spack/share/spack/setup-env.sh && spack env create pre_nimble-mpi-trilinos /opt/spack-nimble-env-mpi-trilinos/spack.yaml\
  && spack env activate pre_nimble-mpi-trilinos && spack concretize && spack env deactivate
# make nimble-mpi-trilinos env from lock
RUN . /opt/spack/share/spack/setup-env.sh && spack env create nimble-mpi-trilinos /opt/spack/var/spack/environments/pre_nimble-mpi-trilinos/spack.lock
# activate nimble-mpi-trilinos env and install
RUN . /opt/spack/share/spack/setup-env.sh && spack env activate nimble-mpi-trilinos && spack install --fail-fast && spack gc -y && spack env deactivate

## Make mpi+Kokkos nimble env
RUN mkdir -p /opt/spack-nimble-env-mpi-kokkos
ADD ./spack-mpi-kokkos.yaml /opt/spack-nimble-env-mpi-kokkos/spack-mpi-kokkos.yaml
RUN mv /opt/spack-nimble-env-mpi-kokkos/spack-mpi-kokkos.yaml /opt/spack-nimble-env-mpi-kokkos/spack.yaml
# create pre_nimble-mpi-kokkos environment from spack.yaml and concretize
RUN cd /opt/spack-nimble-env-mpi-kokkos \
  && . /opt/spack/share/spack/setup-env.sh && spack env create pre_nimble-mpi-kokkos /opt/spack-nimble-env-mpi-kokkos/spack.yaml\
  && spack env activate pre_nimble-mpi-kokkos && spack concretize && spack env deactivate
# make nimble-mpi-kokkos env from lock
RUN . /opt/spack/share/spack/setup-env.sh && spack env create nimble-mpi-kokkos /opt/spack/var/spack/environments/pre_nimble-mpi-kokkos/spack.lock
# activate nimble-mpi-kokkos env and install
RUN . /opt/spack/share/spack/setup-env.sh && spack env activate nimble-mpi-kokkos && spack install --fail-fast && spack gc -y && spack env deactivate

# install mpicpp and p3a
RUN bash /opt/src/NimbleSMBaseImage/install-mpicpp.sh
RUN bash /opt/src/NimbleSMBaseImage/install-p3a.sh

## Make mpi+Kokkos+ArborX nimble env
RUN mkdir -p /opt/spack-nimble-env-mpi-kokkos-arborx
ADD ./spack-mpi-kokkos-arborx.yaml /opt/spack-nimble-env-mpi-kokkos-arborx/spack-mpi-kokkos-arborx.yaml
RUN mv /opt/spack-nimble-env-mpi-kokkos-arborx/spack-mpi-kokkos-arborx.yaml /opt/spack-nimble-env-mpi-kokkos-arborx/spack.yaml
# create pre_nimble-mpi-kokkos-arborx environment from spack.yaml and concretize
RUN cd /opt/spack-nimble-env-mpi-kokkos-arborx \
  && . /opt/spack/share/spack/setup-env.sh && spack env create pre_nimble-mpi-kokkos-arborx /opt/spack-nimble-env-mpi-kokkos-arborx/spack.yaml\
  && spack env activate pre_nimble-mpi-kokkos-arborx && spack concretize && spack env deactivate
# make nimble-mpi-kokkos-arborx env from lock
RUN . /opt/spack/share/spack/setup-env.sh && spack env create nimble-mpi-kokkos-arborx /opt/spack/var/spack/environments/pre_nimble-mpi-kokkos-arborx/spack.lock
# activate nimble-mpi-kokkos-arborx env and install
RUN . /opt/spack/share/spack/setup-env.sh && spack env activate nimble-mpi-kokkos-arborx && spack install --fail-fast && spack gc -y && spack env deactivate

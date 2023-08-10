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

### SERIAL ENVIRONMENTS ###
# Create all serial spack environments

## Make serial nimble env
RUN mkdir -p /opt/spack-nimble-env-serial
ADD ./spack-serial.yaml /opt/spack-nimble-env-serial/spack-serial.yaml
RUN mv /opt/spack-nimble-env-serial/spack-serial.yaml /opt/spack-nimble-env-serial/spack.yaml
# create pre_NimbleSMSerial environment from spack.yaml and concretize
RUN cd /opt/spack-nimble-env-serial \
  && . /opt/spack/share/spack/setup-env.sh && spack env create pre_NimbleSMSerial /opt/spack-nimble-env-serial/spack.yaml\
  && spack env activate pre_NimbleSMSerial && spack concretize && spack env deactivate
# make NimbleSMSerial env from lock
RUN . /opt/spack/share/spack/setup-env.sh && spack env create NimbleSMSerial /opt/spack/var/spack/environments/pre_NimbleSMSerial/spack.lock
# activate NimbleSMSerial env and install
RUN . /opt/spack/share/spack/setup-env.sh && spack env activate NimbleSMSerial && spack install --fail-fast && spack gc -y && spack env deactivate

## Make serial+Trilinos nimble env
RUN mkdir -p /opt/spack-nimble-env-serial-trilinos
ADD ./spack-serial-trilinos.yaml /opt/spack-nimble-env-serial-trilinos/spack-serial-trilinos.yaml
RUN mv /opt/spack-nimble-env-serial-trilinos/spack-serial-trilinos.yaml /opt/spack-nimble-env-serial-trilinos/spack.yaml
# create pre_NimbleSMSerial+Trilinos environment from spack.yaml and concretize
RUN cd /opt/spack-nimble-env-serial-trilinos \
  && . /opt/spack/share/spack/setup-env.sh && spack env create pre_NimbleSMSerial+Trilinos /opt/spack-nimble-env-serial-trilinos/spack.yaml\
  && spack env activate pre_NimbleSMSerial+Trilinos && spack concretize && spack env deactivate
# make NimbleSMSerial+Trilinos env from lock
RUN . /opt/spack/share/spack/setup-env.sh && spack env create NimbleSMSerial+Trilinos /opt/spack/var/spack/environments/pre_NimbleSMSerial+Trilinos/spack.lock
# activate NimbleSMSerial+Trilinos env and install
RUN . /opt/spack/share/spack/setup-env.sh && spack env activate NimbleSMSerial+Trilinos && spack install --fail-fast && spack gc -y && spack env deactivate

## Make serial+Kokkos nimble env
RUN mkdir -p /opt/spack-nimble-env-serial-kokkos
ADD ./spack-serial-kokkos.yaml /opt/spack-nimble-env-serial-kokkos/spack-serial-kokkos.yaml
RUN mv /opt/spack-nimble-env-serial-kokkos/spack-serial-kokkos.yaml /opt/spack-nimble-env-serial-kokkos/spack.yaml
# create pre_NimbleSMSerial+Kokkos environment from spack.yaml and concretize
RUN cd /opt/spack-nimble-env-serial-kokkos \
  && . /opt/spack/share/spack/setup-env.sh && spack env create pre_NimbleSMSerial+Kokkos /opt/spack-nimble-env-serial-kokkos/spack.yaml\
  && spack env activate pre_NimbleSMSerial+Kokkos && spack concretize && spack env deactivate
# make NimbleSMSerial+Kokkos env from lock
RUN . /opt/spack/share/spack/setup-env.sh && spack env create NimbleSMSerial+Kokkos /opt/spack/var/spack/environments/pre_NimbleSMSerial+Kokkos/spack.lock
# activate NimbleSMSerial+Kokkos env and install
RUN . /opt/spack/share/spack/setup-env.sh && spack env activate NimbleSMSerial+Kokkos && spack install --fail-fast && spack gc -y && spack env deactivate

## Make serial+Kokkos+ArborX nimble env
RUN mkdir -p /opt/spack-nimble-env-serial-kokkos-arborx
ADD ./spack-serial-kokkos-arborx.yaml /opt/spack-nimble-env-serial-kokkos-arborx/spack-serial-kokkos-arborx.yaml
RUN mv /opt/spack-nimble-env-serial-kokkos-arborx/spack-serial-kokkos-arborx.yaml /opt/spack-nimble-env-serial-kokkos-arborx/spack.yaml
# create pre_NimbleSMSerial+Kokkos+ArborX environment from spack.yaml and concretize
RUN cd /opt/spack-nimble-env-serial-kokkos-arborx \
  && . /opt/spack/share/spack/setup-env.sh && spack env create pre_NimbleSMSerial+Kokkos+ArborX /opt/spack-nimble-env-serial-kokkos-arborx/spack.yaml\
  && spack env activate pre_NimbleSMSerial+Kokkos+ArborX && spack concretize && spack env deactivate
# make NimbleSMSerial+Kokkos+ArborX env from lock
RUN . /opt/spack/share/spack/setup-env.sh && spack env create NimbleSMSerial+Kokkos+ArborX /opt/spack/var/spack/environments/pre_NimbleSMSerial+Kokkos+ArborX/spack.lock
# activate NimbleSMSerial+Kokkos+ArborX env and install
RUN . /opt/spack/share/spack/setup-env.sh && spack env activate NimbleSMSerial+Kokkos+ArborX && spack install --fail-fast && spack gc -y && spack env deactivate



### MPI ENVIRONMENTS ###
# Create all mpi spack environments

## Make mpi nimble env
RUN mkdir -p /opt/spack-nimble-env-mpi
ADD ./spack-mpi.yaml /opt/spack-nimble-env-mpi/spack-mpi.yaml
RUN mv /opt/spack-nimble-env-mpi/spack-mpi.yaml /opt/spack-nimble-env-mpi/spack.yaml
# create pre_NimbleSMMPI environment from spack.yaml and concretize
RUN cd /opt/spack-nimble-env-mpi \
  && . /opt/spack/share/spack/setup-env.sh && spack env create pre_NimbleSMMPI /opt/spack-nimble-env-mpi/spack.yaml\
  && spack env activate pre_NimbleSMMPI && spack concretize && spack env deactivate
# make NimbleSMMPI env from lock
RUN . /opt/spack/share/spack/setup-env.sh && spack env create NimbleSMMPI /opt/spack/var/spack/environments/pre_NimbleSMMPI/spack.lock
# activate NimbleSMMPI env and install
RUN . /opt/spack/share/spack/setup-env.sh && spack env activate NimbleSMMPI && spack install --fail-fast && spack gc -y && spack env deactivate

## Make mpi+Trilinos nimble env
RUN mkdir -p /opt/spack-nimble-env-mpi-trilinos
ADD ./spack-mpi-trilinos.yaml /opt/spack-nimble-env-mpi-trilinos/spack-mpi-trilinos.yaml
RUN mv /opt/spack-nimble-env-mpi-trilinos/spack-mpi-trilinos.yaml /opt/spack-nimble-env-mpi-trilinos/spack.yaml
# create pre_NimbleSMMPI+Trilinos environment from spack.yaml and concretize
RUN cd /opt/spack-nimble-env-mpi-trilinos \
  && . /opt/spack/share/spack/setup-env.sh && spack env create pre_NimbleSMMPI+Trilinos /opt/spack-nimble-env-mpi-trilinos/spack.yaml\
  && spack env activate pre_NimbleSMMPI+Trilinos && spack concretize && spack env deactivate
# make NimbleSMMPI+Trilinos env from lock
RUN . /opt/spack/share/spack/setup-env.sh && spack env create NimbleSMMPI+Trilinos /opt/spack/var/spack/environments/pre_NimbleSMMPI+Trilinos/spack.lock
# activate NimbleSMMPI+Trilinos env and install
RUN . /opt/spack/share/spack/setup-env.sh && spack env activate NimbleSMMPI+Trilinos && spack install --fail-fast && spack gc -y && spack env deactivate

## Make mpi+Kokkos nimble env
RUN mkdir -p /opt/spack-nimble-env-mpi-kokkos
ADD ./spack-mpi-kokkos.yaml /opt/spack-nimble-env-mpi-kokkos/spack-mpi-kokkos.yaml
RUN mv /opt/spack-nimble-env-mpi-kokkos/spack-mpi-kokkos.yaml /opt/spack-nimble-env-mpi-kokkos/spack.yaml
# create pre_NimbleSMMPI+Kokkos environment from spack.yaml and concretize
RUN cd /opt/spack-nimble-env-mpi-kokkos \
  && . /opt/spack/share/spack/setup-env.sh && spack env create pre_NimbleSMMPI+Kokkos /opt/spack-nimble-env-mpi-kokkos/spack.yaml\
  && spack env activate pre_NimbleSMMPI+Kokkos && spack concretize && spack env deactivate
# make NimbleSMMPI+Kokkos env from lock
RUN . /opt/spack/share/spack/setup-env.sh && spack env create NimbleSMMPI+Kokkos /opt/spack/var/spack/environments/pre_NimbleSMMPI+Kokkos/spack.lock
# activate NimbleSMMPI+Kokkos env and install
RUN . /opt/spack/share/spack/setup-env.sh && spack env activate NimbleSMMPI+Kokkos && spack install --fail-fast && spack gc -y && spack env deactivate

## Make mpi+Kokkos+ArborX nimble env
RUN mkdir -p /opt/spack-nimble-env-mpi-kokkos-arborx
ADD ./spack-mpi-kokkos-arborx.yaml /opt/spack-nimble-env-mpi-kokkos-arborx/spack-mpi-kokkos-arborx.yaml
RUN mv /opt/spack-nimble-env-mpi-kokkos-arborx/spack-mpi-kokkos-arborx.yaml /opt/spack-nimble-env-mpi-kokkos-arborx/spack.yaml
# create pre_NimbleSMMPI+Kokkos+ArborX environment from spack.yaml and concretize
RUN cd /opt/spack-nimble-env-mpi-kokkos-arborx \
  && . /opt/spack/share/spack/setup-env.sh && spack env create pre_NimbleSMMPI+Kokkos+ArborX /opt/spack-nimble-env-mpi-kokkos-arborx/spack.yaml\
  && spack env activate pre_NimbleSMMPI+Kokkos+ArborX && spack concretize && spack env deactivate
# make NimbleSMMPI+Kokkos+ArborX env from lock
RUN . /opt/spack/share/spack/setup-env.sh && spack env create NimbleSMMPI+Kokkos+ArborX /opt/spack/var/spack/environments/pre_NimbleSMMPI+Kokkos+ArborX/spack.lock
# activate NimbleSMMPI+Kokkos+ArborX env and install
RUN . /opt/spack/share/spack/setup-env.sh && spack env activate NimbleSMMPI+Kokkos+ArborX && spack install --fail-fast && spack gc -y && spack env deactivate

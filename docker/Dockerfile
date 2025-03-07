# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    gcc g++ gfortran libgomp1 \
    make cmake libopenblas-dev libopenblas-base \
    libopenmpi-dev libopenmpi3 git libeigen3-dev \
    python3 python3-distutils python3-numpy \
    liblua5.3-0 liblua5.3-dev zlib1g zlib1g-dev \
    wget sudo vim\
    && rm -rf /var/lib/apt/lists/*

# Create user 'tandem' and set up home directory
RUN useradd -m -s /bin/bash tandem && \
    usermod -aG sudo tandem && \
    echo "tandem ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the tandem user
USER tandem
WORKDIR /home/tandem

# Create directories for builds
RUN mkdir -p /home/tandem/petsc

# Download and install PETSc
RUN wget https://web.cels.anl.gov/projects/petsc/download/release-snapshots/petsc-3.22.3.tar.gz && \
    tar -xvf petsc-3.22.3.tar.gz && \
    cd petsc-3.22.3 && \
    ./configure \
     --with-fortran-bindings=0 \
     --with-debugging=0 \
     --with-memalign=32 \
    --with-64-bit-indices \
    CC=mpicc CXX=mpicxx FC=mpif90 \
    COPTFLAGS="-g -O3" CXXOPTFLAGS="-g -O3" \
    --download-mumps \
    --download-scalapack \
    --download-metis \
    --download-parmetis \
    --download-fblaslapack=1 \
    --prefix=/home/tandem/petsc && \
    make PETSC_DIR=/home/tandem/petsc-3.22.3 PETSC_ARCH=arch-linux-c-opt all && \
    make PETSC_DIR=/home/tandem/petsc-3.22.3 PETSC_ARCH=arch-linux-c-opt install && \
    cd .. && rm -rf petsc-3.22.3*

RUN mkdir -p /home/tandem/build_2d_6p
# Clone and build Tandem
RUN git clone https://github.com/TEAR-ERC/tandem.git

RUN    cd tandem && \
    git submodule update --init && \
    git checkout dmay/staging && \
    cd ../build_2d_6p && \
    cmake /home/tandem/tandem -DCMAKE_CXX_COMPILER=mpicxx -DCMAKE_C_COMPILER=mpicc -DCMAKE_PREFIX_PATH=/home/tandem/petsc -DDOMAIN_DIMENSION=2 -DPOLYNOMIAL_DEGREE=6 && \
    make -j

RUN rm -rf /home/tandem/tandem

# Set the default working directory to tandem's home
RUN mkdir /home/tandem/storage
RUN chown -R tandem:tandem /home/tandem/storage
COPY --chown=tandem:tandem simulation_configs/ /home/tandem/casc
# Change ownership of home directory
RUN chown -R tandem:tandem /home/tandem

WORKDIR /home/tandem

# Create a welcome message
RUN echo 'export OMP_NUM_THREADS=1' >> /home/tandem/.bashrc && \
    echo 'echo "Welcome to the Tandem development environment!"' >> /home/tandem/.bashrc && \
    echo 'echo "PETSc is installed in: ~/petsc"' >> /home/tandem/.bashrc && \
    echo 'echo "Tandem is located in: ~/tandem"' >> /home/tandem/.bashrc
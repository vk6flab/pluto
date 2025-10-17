# URLs for the three repositories
ARG LIBIIO_URL="https://github.com/analogdevicesinc/libiio.git"
ARG LIBAD9361_URL="https://github.com/analogdevicesinc/libad9361-iio.git"
ARG IIO_OSCILLOSCOPE_URL="https://github.com/analogdevicesinc/iio-oscilloscope.git"

# URL and filter for latest Pluto firmware
ARG PLUTO_FIRMWARE_URL="https://api.github.com/repos/analogdevicesinc/plutosdr-fw/releases/latest"
ARG JQ_FILTER='.assets[] | select(.content_type == "application/zip") | .browser_download_url'

# URL for the ssh configuration file
ARG SSH_CONFIG="https://raw.githubusercontent.com/analogdevicesinc/plutosdr_scripts/refs/heads/master/ssh_config"

##############################################################################
FROM debian:stable-slim AS builder
##############################################################################
#
# Compile the tools from source
#
##############################################################################
ARG LIBIIO_URL
ARG LIBAD9361_URL
ARG IIO_OSCILLOSCOPE_URL

# We don't want to answer questions during the build stage
ARG DEBIAN_FRONTEND=noninteractive

# Update the current image
RUN apt-get update
RUN apt-get -y upgrade

# Prerequisites for compiling from source
RUN apt-get -y install \
	git \
	build-essential
	
# Install Prerequisites
RUN apt-get -y install \
	libxml2-dev \
	libzstd-dev \
	bison \
	flex \
	libcdk5-dev \
	cmake
	
# Install libraries for Backends
RUN apt-get -y install \
	libaio-dev \
	libusb-1.0-0-dev

# Install libraries for Backends
RUN apt-get -y install \
	libserialport-dev \
	libavahi-client-dev

# Install to build doc
RUN apt-get -y install \
	doxygen \
	graphviz

# Install to build python backends
RUN apt-get -y install \
	python3 \
	python3-pip \
	python3-setuptools

# Get the sources
WORKDIR /src
## Workaround for unsupported main branch
RUN git clone --depth 1 --branch v0.25 "${LIBIIO_URL}"
RUN git clone --depth 1 "${LIBAD9361_URL}"
RUN git clone --depth 1 "${IIO_OSCILLOSCOPE_URL}"

# Build libiio
WORKDIR /src/libiio/build
RUN cmake ../ -DCPP_BINDINGS=ON -DPYTHON_BINDINGS=ON
RUN make -j$(nproc)
RUN make install
## Install a copy so we can use it in the run stage
RUN make install DESTDIR=/src/root/

# Build libad9361-iio
WORKDIR /src/libad9361-iio/build
RUN cmake ../CMakeLists.txt
RUN make -j$(nproc)
RUN make install
## Install a copy so we can use it in the run stage
RUN make install DESTDIR=/src/root/

# Dependencies for iio-oscilloscope
RUN apt-get -y install \
	libglib2.0-dev \
	libgtk-3-dev \
	libgtkdatabox-dev \
	libmatio-dev \
	libfftw3-dev \
	libxml2 \
	libxml2-dev \
	bison \
	flex \
	libavahi-common-dev \
	libavahi-client-dev \
	libcurl4-openssl-dev \
	libjansson-dev \
	cmake \
	libaio-dev \
	libserialport-dev

# Build iio-oscilloscope
WORKDIR /src/iio-oscilloscope/build
RUN cmake ../
RUN make -j$(nproc)
RUN make install
## Install a copy so we can use it in the run stage
RUN make install DESTDIR=/src/root/

# Package up the installed items
## Fix an issue where Debian no longer supports /lib
RUN mv /src/root/lib/* /src/root/usr/lib/
RUN rmdir /src/root/lib
## Package up all the installed parts so we can use them in the run stage
RUN tar -zcf /src/pluto.tgz --directory=/src/root/  .

##############################################################################
FROM debian:stable-slim AS firmware
##############################################################################
#
# Get the latest firmware from GitHub
#
##############################################################################
ARG PLUTO_FIRMWARE_URL
ARG JQ_FILTER

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get -y upgrade

# Install the prerequisites to get the latest firmware from GitHub
RUN apt-get -y install \
	jq \
	wget

# Get the details of the latest firmware
ADD "${PLUTO_FIRMWARE_URL}" /tmp/latest.json

# Extract and download the various release files
WORKDIR /src/latest
RUN jq -r "${JQ_FILTER}" /tmp/latest.json | wget -i-

##############################################################################
FROM debian:stable-slim
##############################################################################
#
# Actual container that will be run
#
##############################################################################
ARG SSH_CONFIG

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get -y upgrade

# We need access to ssh so we can connect to the PlutoSDR
RUN apt-get -y install \
	openssh-client \
	unzip

# Install the dependencies for iio-oscilloscope
RUN apt-get -y install \
	libgtk-3-0t64 \
	libusb-1.0-0 \
	libgtkdatabox1t64 \
	libfftw3-double3 \
	libcurl4t64 \
	libserialport0 \
	libjansson4 \
	libmatio13

# Install the build artefacts from the build stage	
WORKDIR /
COPY --from=builder /src/pluto.tgz .
RUN tar -zxf pluto.tgz
RUN rm pluto.tgz

# Appears to be required to point at all the libraries we just installed
RUN ldconfig

# Set up a new unprivileged user
RUN useradd -ms /bin/bash docker
WORKDIR /home/docker

# Copy the files from the firmware stage
COPY --chmod=444 --from=firmware /src/latest/* .

# Configure SSH so it doesn't complain if you reboot the PlutoSDR
ADD --chmod=600 "${SSH_CONFIG}" .ssh/config

# Make sure that the user can actually use the files
RUN chown -R docker:docker .
RUN chmod 700 .ssh

# Switch to the unprivileged user
USER docker
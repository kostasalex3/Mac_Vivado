FROM ubuntu:18.04
LABEL version="2.0" description="Vivado image"

RUN dpkg --add-architecture i386 && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  autoconf \
  bc \
  bison \
  build-essential \
  chrpath \
  cpio \
  diffstat \
  dos2unix \
  expect \
  fakeroot \
  flex \
  gawk \
  gcc-7 \
  gcc-multilib \
  git \
  gnupg \
  gzip \
  iproute2 \
  less \
  libglib2.0-dev \
  libgtk2.0-0 \
  libgtk2.0-dev \
  libncurses5-dev \
  libsdl1.2-dev \
  libselinux1 \
  libssl-dev \
  libtool \
  libtool-bin \
  locales \
  lsb-release \
  make \
  nano \
  net-tools \
  pax \
  python3-gi \
  python3.6 \
  rsync \
  screen \
  socat \
  software-properties-common \
  sudo \
  tar \
  texinfo \
  tftpd-hpa \
  tofrodos \
  unzip \
  update-inetd \
  vim \
  wget \
  xorg \
  xterm \
  xvfb \
  zlib1g-dev \
  zlib1g-dev:i386 \
  && update-alternatives --install /usr/bin/python python /usr/bin/python2.7 2 \
  && add-apt-repository ppa:deadsnakes/ppa && apt update \
  && apt-get install -y python3.6 && update-alternatives --install /usr/bin/python python /usr/bin/python3.6 1 \
  && apt-get autoremove --purge && apt-get autoclean && update-alternatives --auto python

# Install the repo tool to handle git submodules (meta layers) comfortably.
ADD https://storage.googleapis.com/git-repo-downloads/repo /usr/local/bin/
RUN chmod 755 /usr/local/bin/repo

RUN echo "%sudo ALL=(ALL:ALL) ALL" >> /etc/sudoers \
  && echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# The Xilinx toolchain version
ARG XILVER=2017.4

# Add user 'mac_vivado' with password 'mac_vivado' and give it access to install directory /opt
RUN useradd -m -G dialout,sudo -s /bin/bash mac_vivado \
  && echo "mac_vivado:mac_vivado" | chpasswd \
  && chmod +w /opt \
  && chown -R mac_vivado:mac_vivado /opt 

# Set folder for tftp server
RUN mkdir -p /tftpboot && chmod 666 /tftpboot \
  && sed -i 's/TFTP\_USERNAME\=\"tftp\"/TFTP\_USERNAME\=\"mac_vivado\"/g' /etc/default/tftpd-hpa \
  && sed -i 's/var\/lib\/tftpboot/tftpboot/g' /etc/default/tftpd-hpa \
  && sed -i 's/secure/secure \-\-create/g' /etc/default/tftpd-hpa

# set bash as default shell
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# Install under /opt, with user mac_vivado
WORKDIR /opt
USER mac_vivado

# The HTTP server to retrieve the files from.
ARG HTTP_SERV=http://host.docker.internal:8000/resources

# The Vivado build number
ARG XXXX_X=1216_1

# Install Vivado
# Files are expected in the "./resources" subdirectory
ENV XLNX_VIVADO_OFFLINE_INSTALLER=Xilinx_Vivado_SDK_${XILVER}_${XXXX_X}.tar.gz
ENV XLNX_VIVADO_BATCH_CONFIG_FILE=install_config.txt
RUN mkdir -p /opt/Xilinx/tmp \
  && cd /opt/Xilinx/tmp \
  && wget -q ${HTTP_SERV}/$XLNX_VIVADO_BATCH_CONFIG_FILE \
  && wget -q ${HTTP_SERV}/$XLNX_VIVADO_OFFLINE_INSTALLER \
  && cat $XLNX_VIVADO_BATCH_CONFIG_FILE \
  && tar -zxf $XLNX_VIVADO_OFFLINE_INSTALLER && ls -al \
  && mv $XLNX_VIVADO_BATCH_CONFIG_FILE Xilinx_Vivado_SDK_${XILVER}_${XXXX_X}/ \
  && cd Xilinx_Vivado_SDK_${XILVER}_${XXXX_X} \
  && chmod a+x xsetup \
  && ./xsetup \
    --agree XilinxEULA,3rdPartyEULA,WebTalkTerms \
    --config $XLNX_VIVADO_BATCH_CONFIG_FILE \
    --batch INSTALL \
  && cd $HOME_DIR \
  && rm -rf /opt/Xilinx/tmp

# Source settings at login
USER root
RUN echo "/usr/sbin/in.tftpd --foreground --listen --address [::]:69 --secure /tftpboot" >> /etc/profile \
  && echo ". /opt/Xilinx/Vivado/${XILVER}/settings64.sh" >> /etc/profile \
  && echo ". /etc/profile" >> /root/.profile

EXPOSE 69/udp
ENV SHELL /bin/bash
USER mac_vivado

RUN export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/Xilinx/Vivado/${XILVER}/lib/lnx64.o/

# incorporate Vivado license file or ENV LM_LICENSE_SERVER=portNum@ipAddrOfLicenseServer

ENTRYPOINT ["/bin/bash", "-l"]

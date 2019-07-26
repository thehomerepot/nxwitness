FROM lsiobase/ubuntu:bionic
MAINTAINER Ryan Flagler

# global environment settings
ENV DEBIAN_FRONTEND="noninteractive" \
COMPANY_NAME="networkoptix" \
SOFTWARE_URL="http://updates.networkoptix.com/default/29227/linux/nxwitness-server-4.0.0.29227-linux64-beta-prod.deb"

# install packages
RUN \
 apt-get update && \
 apt-get install -y \
        python \
        upstart-job \
        psmisc \
        upstart \
        libsm6 \
        libice6 \
        libaudio2 \
        libogg0 \
        libxfixes3 \
        libxrender1 \
        unzip \
        fontconfig-config \
        fonts-dejavu-core \
        libdrm-amdgpu1 \
        libdrm-intel1 \
        libdrm-nouveau2 \
        libdrm-radeon1 \
        libfontconfig1 \
        libgl1-mesa-dri \
        libgl1-mesa-glx \
        libglapi-mesa \
        libllvm4.0 \
        libpciaccess0 \
        libsensors4 \
        libtxc-dxtn-s2tc0 \
        libx11-xcb1 \
        libxcb-dri2-0 \
        libxcb-dri3-0 \
        libxcb-glx0 \
        libxcb-present0 \
        libxcb-sync1 \
        libxdamage1 \
        libxshmfence1 \
        libxxf86vm1 \
        mtools \
        syslinux \
        net-tools \
        libglib2.0 \
        cifs-utils \
        syslinux-common && \

# install
 mkdir -p /opt/deb && \
 cd /opt/deb && \
 curl -O -L \
	"${SOFTWARE_URL}" && \
 dpkg-deb -R $(ls *.deb) extracted && \
 rm -rf ./extracted/etc/init.d && \
 sed -i '/service apport stop/q' ./extracted/DEBIAN/postinst && \
 dpkg-deb -b extracted ${COMPANY_NAME}.deb && \
 echo ${COMPANY_NAME} ${COMPANY_NAME}-mediaserver/accepted-mediaserver-eula boolean true | debconf-set-selections && \
 dpkg -i ${COMPANY_NAME}.deb && \

# cleanup
 apt-get clean && \
 rm -rf \
	/opt/deb \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/*

# add local files
COPY root/ /
		
# ports and volumes
EXPOSE 7001
VOLUME /config /archive

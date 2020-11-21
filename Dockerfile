FROM lsiobase/ubuntu:focal
MAINTAINER Ryan Flagler

# global environment settings
ENV DEBIAN_FRONTEND="noninteractive" \
COMPANY_NAME="networkoptix" \
SOFTWARE_URL="https://updates.networkoptix.com/default/32045/linux/nxwitness-server-4.1.0.32045-linux64-patch.deb"

# install packages
RUN \
        apt-get update && \
        apt-get install -y \
                cifs-utils \
                dbus \
                fontconfig-config \
                fonts-dejavu-core \
                gdb \
                gdbserver \
                libapparmor1 \
                libasound2 \
                libasound2-data \
                libasound2-plugins \
                libaudio2 \
                libavahi-client3 \
                libavahi-common3 \
                libavahi-common-data \
                libbabeltrace1 \
                libbsd0 \
                libc6-dbg \
                libcap2 \
                libcap2-bin \
                libcc1-0 \
                libcups2 \
                libdbus-1-3 \
                libdrm2 \
                libdrm-amdgpu1 \
                libdrm-common \
                libdrm-intel1 \
                libdrm-nouveau2 \
                libdrm-radeon1 \
                libdw1 \
                libedit2 \
                libelf1 \
                libfontconfig1 \
                libfreetype6 \
                libgl1 \
                libgl1-mesa-dri \
                libgl1-mesa-glx \
                libglapi-mesa \
                libglib2.0-0 \
                libglib2.0-data \
                libglvnd0 \
                libglx0 \
                libglx-mesa0 \
                libice6 \
                libicu60 \
                libjansson4 \
                libldb1 \
                libllvm8 \
                libmpdec2 \
                libmpfr6 \
                libogg0 \
                libpam-cap \
                libpciaccess0 \
                libpng16-16 \
                libpopt0 \
                libpython2.7 \
                libpython2.7-minimal \
                libpython2.7-stdlib \
                libpython3.6 \
                libpython3.6-minimal \
                libpython3.6-stdlib \
                libpython-stdlib \
                libsensors4 \
                libsm6 \
                libtalloc2 \
                libtdb1 \
                libtevent0 \
                libwbclient0 \
                libx11-6 \
                libx11-data \
                libx11-xcb1 \
                libxau6 \
                libxcb1 \
                libxcb-dri2-0 \
                libxcb-dri3-0 \
                libxcb-glx0 \
                libxcb-present0 \
                libxcb-shape0 \
                libxcb-sync1 \
                libxcb-xfixes0 \
                libxdamage1 \
                libxdmcp6 \
                libxext6 \
                libxfixes3 \
                libxml2 \
                libxrender1 \
                libxshmfence1 \
                libxt6 \
                libxxf86vm1 \
                multiarch-support \
                net-tools \
                psmisc \
                python \
                python2.7 \
                python2.7-minimal \
                python-crypto \
                python-ldb \
                python-minimal \
                python-samba \
                python-talloc \
                python-tdb \
                samba-common \
                samba-common-bin \
                samba-libs \
                shared-mime-info \
                ucf \
                x11-common \
                xdg-user-dirs && \
# modify user
        usermod -l $COMPANY_NAME abc && \
        groupmod -n $COMPANY_NAME abc && \
        sed -i "s/abc/\$COMPANY_NAME/g" /etc/cont-init.d/10-adduser && \
# install
        mkdir -p /opt/deb && \
        cd /opt/deb && \
        curl -O -L "${SOFTWARE_URL}" && \
        dpkg-deb -R $(ls *.deb) extracted && \
        sed -i 's/systemd.*), //' ./extracted/DEBIAN/control && \
        sed -i '/# Dirty hack to prevent/q' ./extracted/DEBIAN/postinst && \
        sed -i "/systemctl.*stop/s/ ||/ 2>\/dev\/null ||/g" ./extracted/DEBIAN/postinst && \
        sed -i 's/systemd-detect-virt/echo "none"/' ./extracted/DEBIAN/postinst && \
        sed -i '/^    su/d; /--chuid/d' ./extracted/opt/${COMPANY_NAME}/mediaserver/bin/mediaserver && \
        rm -rf ./extracted/etc && \
        dpkg-deb -b extracted ${COMPANY_NAME}.deb && \
        echo ${COMPANY_NAME} ${COMPANY_NAME}-mediaserver/accepted-mediaserver-eula boolean true | debconf-set-selections && \
        echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
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

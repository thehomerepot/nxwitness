FROM lsiobase/ubuntu:focal
MAINTAINER Ryan Flagler

# global environment settings
ENV DEBIAN_FRONTEND="noninteractive" \
COMPANY_NAME="networkoptix" \
SOFTWARE_URL="https://updates.networkoptix.com/default/32045/linux/nxwitness-server-4.1.0.32045-linux64-patch.deb"

# install packages
RUN \
        apt-get update && \
        apt-get install -y && \
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
        apt install -y /opt/deb/${COMPANY_NAME}.deb && \
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

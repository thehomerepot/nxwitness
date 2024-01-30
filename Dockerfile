FROM lsiobase/ubuntu:focal
MAINTAINER Ryan Flagler

# global environment settings
ENV COMPANY_NAME="networkoptix"
ENV SOFTWARE_URL="https://updates.networkoptix.com/default/5.1.2.37996/linux/nxwitness-server-5.1.2.37996-linux_x64.deb"

# pull installer
RUN     mkdir -p /opt/deb && \
        curl -o /opt/deb/${COMPANY_NAME}.deb -L "${SOFTWARE_URL}"
        
# modify user
RUN     usermod -l $COMPANY_NAME abc && \
        groupmod -n $COMPANY_NAME abc && \
        sed -i "s/abc/\$COMPANY_NAME/g" /etc/s6-overlay/s6-rc.d/init-adduser/run

# extract package and modify postinst
RUN     cd /opt/deb && \
        dpkg-deb -R $(ls *.deb) extracted && \
        sed -i '/^reloadServices$/d' ./extracted/DEBIAN/postinst && \
        dpkg-deb -b extracted ${COMPANY_NAME}.deb

# Set noninteractive
RUN     echo "debconf debconf/frontend select noninteractive" | debconf-set-selections

# install packages
RUN     apt-get update && \
        apt-get install --no-install-recommends --yes \
                gdb \
                /opt/deb/${COMPANY_NAME}.deb && \
        apt-get clean && \
        apt-get autoremove --purge && \
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

FROM lsiobase/ubuntu:bionic
MAINTAINER Ryan Flagler

# global environment settings
ENV DEBIAN_FRONTEND="noninteractive" \
COMPANY_NAME="networkoptix" \
SOFTWARE_URL="https://updates.networkoptix.com/default/32405/linux/nxwitness-server-4.1.0.32405-linux64-patch.deb"

# pull installer
RUN \
        mkdir -p /opt/deb && \
        curl -o /opt/deb/${COMPANY_NAME}.deb -L "${SOFTWARE_URL}"
# install packages
RUN \
        apt-get update && \
        apt-get install --no-install-recommends --yes \
            gdb \
            /opt/deb/${COMPANY_NAME}.deb && \
# modify user
        usermod -l $COMPANY_NAME abc && \
        groupmod -n $COMPANY_NAME abc && \
        sed -i "s/abc/\$COMPANY_NAME/g" /etc/cont-init.d/10-adduser && \
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

FROM ubuntu:16.04
MAINTAINER Christophe Brunner


ENV DEBIAN_FRONTEND=noninteractive

RUN set -xe \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl socat \
    && apt-get install -y --no-install-recommends xvfb x11vnc fluxbox xterm \
    && apt-get install -y --no-install-recommends sudo \
    && apt-get install -y --no-install-recommends supervisor \
    && rm -rf /var/lib/apt/lists/*

RUN set -xe \
    && curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
	apt-get install -y binutils && \
	apt-get install -y xz-utils

COPY get-latest-chrome.sh /get-latest-chrome.sh

RUN chmod +x /get-latest-chrome.sh

RUN /get-latest-chrome.sh

RUN apt-get update && \
 	apt-get install -y gstreamer-1.0* && \
 	apt-get install -y gstreamer1.0* && \
	apt-get install -y unzip && \
	apt-get install -y vim && \
	apt-get install -y libboost-all-dev && \
	apt-get install -y ffmpeg

RUN mkdir /var/lib/widevine && \ 
    cp /opt/google/chrome/libwidevinecdm.so /var/lib/widevine/libwidevinecdm.so && \
    mv /opt/google/chrome/libwidevinecdm.so /var/lib/widevine/libwidevinecdm_orig.so && \
    ln -s /var/lib/widevine/libwidevinecdm.so /opt/google/chrome/libwidevinecdm.so

RUN set -xe \
    && useradd -u 1000 -g 100 -G sudo --shell /bin/bash --no-create-home --home-dir /tmp user \
    && echo 'ALL ALL = (ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

COPY supervisord.conf /etc/
COPY entry.sh /

RUN chmod +x /entry.sh

VOLUME /var/lib/widevine

User user
WORKDIR /tmp
VOLUME /tmp/chrome-data

CMD ["/entry.sh"]


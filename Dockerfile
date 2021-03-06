FROM ghcr.io/linuxserver/baseimage-mono:LTS

# set version label
ARG BUILD_DATE
ARG VERSION
ARG RADARR_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_CONFIG_HOME="/config/xdg"

# set env variables needed for subliminal to run
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN \
 echo "**** install jq ****" && \
 apt-get update && \
 apt-get install -y \
	jq \
    python3 \
    python3-pip \
    nodejs \
    at && \
 echo "**** install radarr ****" && \
 if [ -z ${RADARR_RELEASE+x} ]; then \
	RADARR_RELEASE=$(curl -sX GET "https://api.github.com/repos/Radarr/Radarr/releases" \
	| jq -r '.[0] | .tag_name'); \
 fi && \
 radarr_url=$(curl -s https://api.github.com/repos/Radarr/Radarr/releases/tags/"${RADARR_RELEASE}" \
	|jq -r '.assets[].browser_download_url' |grep linux) && \
 mkdir -p \
	/app/radarr/bin && \
 curl -o \
 /tmp/radar.tar.gz -L \
	"${radarr_url}" && \
 tar ixzf \
 /tmp/radar.tar.gz -C \
	/app/radarr/bin --strip-components=1 && \
echo "**** install subliminal ****" && \
 pip3 install subliminal && \
 echo "**** clean up ****" && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY /root /

# set run-subliminal permissions
RUN chmod +x /opt/run-subliminal

# ports and volumes
EXPOSE 7878
VOLUME /config

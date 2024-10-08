FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntunoble

# Set version label
ARG BUILD_DATE
ARG VERSION
ARG FIREFOX_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# Title
ENV TITLE=Firefox

# Copy preferences to disable snap installation for Firefox
COPY /root/etc/apt/preferences.d/firefox-no-snap /etc/apt/preferences.d/firefox-no-snap

RUN \
  echo "**** Add icon ****" && \
  curl -o /kclient/public/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/firefox-logo.png && \
  echo "**** Install packages ****" && \
  # Add GPG key
  curl -fsSL https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xAEBDF4819BE21867 | \
    gpg --dearmor -o /usr/share/keyrings/mozillateam-archive-keyring.gpg && \
  # Add Firefox PPA
  echo "deb [signed-by=/usr/share/keyrings/mozillateam-archive-keyring.gpg] https://ppa.launchpadcontent.net/mozillateam/ppa/ubuntu noble main" > \
    /etc/apt/sources.list.d/firefox.list && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    firefox-nightly \
    ^firefox-locale && \
  echo "**** Configure Firefox settings ****" && \
  FIREFOX_SETTING="/usr/lib/firefox/browser/defaults/preferences/firefox.js" && \
  echo 'pref("datareporting.policy.firstRunURL", "");' > ${FIREFOX_SETTING} && \
  echo 'pref("datareporting.policy.dataSubmissionEnabled", false);' >> ${FIREFOX_SETTING} && \
  echo 'pref("datareporting.healthreport.service.enabled", false);' >> ${FIREFOX_SETTING} && \
  echo 'pref("datareporting.healthreport.uploadEnabled", false);' >> ${FIREFOX_SETTING} && \
  echo 'pref("trailhead.firstrun.branches", "nofirstrun-empty");' >> ${FIREFOX_SETTING} && \
  echo 'pref("browser.aboutwelcome.enabled", false);' >> ${FIREFOX_SETTING} && \
  echo "**** Cleanup ****" && \
  rm -rf /var/lib/apt/lists/* /tmp/*

# Add local files
COPY /root /

# Ports and volumes
EXPOSE 3000
VOLUME /config

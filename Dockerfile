FROM ghcr.io/linuxserver/baseimage-kasmvnc:fedora39


# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# USER root

RUN \
  echo "**** install packages ****" && \
  dnf install -y --setopt=install_weak_deps=False --best \
    i3 \ 
    i3status \ 
    xfce4-terminal \
    thunar \ 
    dmenu \
    feh \
    python3-pip \
    ImageMagick \ 
    vim-enhanced \
    psmisc \
    picom \ 
    rofi \ 
    # polybar \ 
    dunst \ 
    xrdb \ 
    git \
    wget \
    chromium \
    pavucontrol \ 
    dolphin \
    xrandr \ 
    # qt5ct \
    # xfce4-power-manager \ 
    # NetworkManager \ 
    # neofetch \ 
    # firefox \
    # kate \
    && \
    pip install pywal 

# RUN  echo "**** cleanup ****" && \
#   dnf autoremove -y && \
#   dnf clean all && \
#   rm -rf \
#     /config/.cache \
#     /tmp/*

# add local files
COPY /root /
COPY /i3config /config/.config/

# ports and volumes
EXPOSE 3000
VOLUME /config

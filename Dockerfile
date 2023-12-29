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
    dmenu \
    feh \
    python3-pip \
    ImageMagick \ 
    # polybar \ 
    # picom \ 
    # xrdb \ 
    # rofi \ 
    # dunst \ 
    # git \
    # wget \
    # qt5ct \
    # xfce4-power-manager \ 
    # chromium \
    # vim-enhanced \
    # dolphin \
    # NetworkManager \ 
    # neofetch \ 
    # xrandr \ 
    # pavucontrol \ 
    # psmisc \
    # firefox \
    # dolphin \
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

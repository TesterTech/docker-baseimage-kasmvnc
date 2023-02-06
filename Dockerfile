FROM ghcr.io/linuxserver/baseimage-alpine:3.17 as buildstage

ARG KASMVNC_RELEASE="1.0.1"
ARG KASMWEB_RELEASE="1.12.0"

RUN \
  echo "**** install build deps ****" && \
  apk add \
    alpine-sdk \
    autoconf \
    automake \
    cmake \
    xorg-server-dev \
    eudev-dev \
    font-cursor-misc \
    font-misc-misc \
    font-util-dev \
    git \
    grep \
    libdrm-dev \
    libepoxy-dev \
    libjpeg-turbo-dev \
    libpciaccess-dev \
    libtool \
    libwebp-dev \
    libx11-dev \
    libxau-dev \
    libxcb-dev \
    libxcursor-dev \
    libxcvt-dev \
    libxdmcp-dev \
    libxext-dev \
    libxfont2-dev \
    libxkbfile-dev \
    libxrandr-dev \
    libxshmfence-dev \
    libxtst-dev \
    mesa-dev \
    mesa-dri-gallium \
    meson \
    nettle-dev \
    openssl-dev \
    pixman-dev \
    tar \
    wayland-dev \
    wayland-protocols \
    xcb-util-dev \
    xcb-util-image-dev \
    xcb-util-keysyms-dev \
    xcb-util-renderutil-dev \
    xcb-util-wm-dev \
    xinit \
    xkbcomp \
    xkbcomp-dev \
    xkeyboard-config \
    xorgproto \
    xorg-server-common \
    xtrans && \
  echo "**** build kasmvnc ****" && \
  git clone https://github.com/kasmtech/KasmVNC.git src && \
  cd /src && \
  git checkout -f release/${KASMVNC_release} && \
  sed -i \
    -e '/find_package(FLTK/s@^@#@' \
    -e '/add_subdirectory(tests/s@^@#@' \
    CMakeLists.txt && \
  cmake -D CMAKE_BUILD_TYPE=RelWithDebInfo . -DBUILD_VIEWER:BOOL=OFF -DENABLE_GNUTLS:BOOL=OFF && \
  make -j4 && \
  echo "**** build xorg ****" && \
  XORG_VER="1.20.7" && \
  XORG_PATCH=$(echo "$XORG_VER" | grep -Po '^\d.\d+' | sed 's#\.##') && \
  wget --no-check-certificate \
    -O /tmp/xorg-server-${XORG_VER}.tar.bz2 \
    "https://www.x.org/archive/individual/xserver/xorg-server-${XORG_VER}.tar.bz2" && \
  tar --strip-components=1 \
    -C unix/xserver \
    -xf /tmp/xorg-server-${XORG_VER}.tar.bz2 && \
  cd unix/xserver && \
  patch -Np1 -i ../xserver${XORG_PATCH}.patch && \
  patch -s -p0 < ../CVE-2022-2320-v1.20.patch && \
  autoreconf -i && \
  ./configure --prefix=/opt/kasmweb \
    --with-xkb-path=/usr/share/X11/xkb \
    --with-xkb-output=/var/lib/xkb \
    --with-xkb-bin-directory=/usr/bin \
    --with-default-font-path="/usr/share/fonts/X11/misc,/usr/share/fonts/X11/cyrillic,/usr/share/fonts/X11/100dpi/:unscaled,/usr/share/fonts/X11/75dpi/:unscaled,/usr/share/fonts/X11/Type1,/usr/share/fonts/X11/100dpi,/usr/share/fonts/X11/75dpi,built-ins" \
    --with-sha1=libcrypto \
    --without-dtrace --disable-dri \
    --disable-static \
    --disable-xinerama \
    --disable-xvfb \
    --disable-xnest \
    --disable-xorg \
    --disable-dmx \
    --disable-xwin \
    --disable-xephyr \
    --disable-kdrive \
    --disable-config-hal \
    --disable-config-udev \
    --disable-dri2 \
    --enable-glx \
    --disable-xwayland \
    --disable-dri3 && \
  find . -name "Makefile" -exec sed -i 's/-Werror=array-bounds//g' {} \; && \
  make -j4 && \
  echo "**** generate final output ****" && \
  cd /src && \
  mkdir -p xorg.build/bin && \
  cd xorg.build/bin/ && \
  ln -s /src/unix/xserver/hw/vnc/Xvnc Xvnc && \
  cd .. && \
  mkdir -p man/man1 && \
  touch man/man1/Xserver.1 && \
  cp /src/unix/xserver/hw/vnc/Xvnc.man man/man1/Xvnc.1 && \
  mkdir lib && \
  cd lib && \
  ln -s /usr/lib/xorg/modules/dri dri && \
  cd /src && \
  mkdir -p builder/www && \
  curl -s https://kasm-ci.s3.amazonaws.com/kasmweb-${KASMWEB_RELEASE}.tar.gz \
    | tar xzf - -C builder/www && \
  make servertarball && \
  mkdir /build-out && \
  tar xzf \
    kasmvnc-Linux*.tar.gz \
    -C /build-out/


# runtime stage
FROM ghcr.io/linuxserver/baseimage-alpine:3.17

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# env
ENV DISPLAY=:1 \
    NVIDIA_DRIVER_CAPABILITIES=${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics,compat32,utility

# copy over build output
COPY --from=buildstage /build-out/ /

RUN \
  echo "**** install deps ****" && \
  apk add --no-cache \
    bash \
    ca-certificates \
    font-noto \
    libgcc \
    libgomp \
    libjpeg-turbo \
    libstdc++ \
    libwebp \
    libxfont2 \
    mcookie \
    mesa-gl \
    openbox \
    openssl \
    perl \
    perl-hash-merge-simple \
    perl-list-moreutils \
    perl-switch \
    perl-try-tiny \
    perl-yaml-tiny \
    pixman \
    pulseaudio \
    py3-xdg \
    python3 \
    setxkbmap \
    sudo \
    xauth \
    xkeyboard-config \
    xkbcomp \
    xterm && \
  echo "**** filesystem setup ****" && \
  ln -s /usr/local/share/kasmvnc /usr/share/kasmvnc && \
  ln -s /usr/local/etc/kasmvnc /etc/kasmvnc && \
  ln -s /usr/local/lib/kasmvnc /usr/lib/kasmvncserver && \
  echo "**** openbox tweaks ****" && \
  sed -i \
    's/NLIMC/NLMC/g' \
    /etc/xdg/openbox/rc.xml && \
  echo "**** cleanup and user perms ****" && \
  echo "abc:abc" | chpasswd && \
  usermod -s /bin/bash abc && \
  echo '%wheel ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/wheel && \
  adduser abc wheel && \
  rm -rf \
    /tmp/*


# add local files
COPY /root /

# ports and volumes
EXPOSE 6901
VOLUME /config


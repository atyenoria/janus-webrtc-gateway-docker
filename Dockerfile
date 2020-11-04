FROM buildpack-deps:stretch

RUN sed -i 's/archive.ubuntu.com/mirror.aarnet.edu.au\/pub\/ubuntu\/archive/g' /etc/apt/sources.list

RUN rm -rf /var/lib/apt/lists/*
RUN apt-get -y update && apt-get install -y \
    libjansson-dev \
    libnice-dev \
    libssl-dev \
    libsrtp-dev \
    libsofia-sip-ua-dev \
    libglib2.0-dev \
    libopus-dev \
    libogg-dev \
    libini-config-dev \
    libcollection-dev \
    libconfig-dev \
    pkg-config \
    gengetopt \
    libtool \
    autopoint \
    automake \
    build-essential \
    subversion \
    git \
    cmake \
    unzip \
    zip \
    lsof wget vim sudo rsync cron mysql-client openssh-server supervisor locate mplayer valgrind certbot python-certbot-apache dnsutils tcpdump gstreamer1.0-tools


# RUN apt-get install -y libx264-dev libmatroska-dev libopus-dev libssl1.0-dev libtheora-dev libogg-dev python3-pip flex bison libsoup2.4-dev libjpeg-dev nasm libvpx-dev
# RUN sudo pip3 install meson ninja
# RUN git clone https://gitlab.freedesktop.org/gstreamer/gst-build
# WORKDIR /gst-build
# RUN git log -n 1 HEAD
# RUN git checkout 1016bf23
# RUN git log -n 1 HEAD
# RUN mkdir builddir
# # RUN meson builddir
# RUN meson builddir
# RUN ninja -C builddir update
# RUN ninja install -C builddir
# RUN ldconfig
# RUN which gst-launch-1.0
# RUN ldd /usr/local/bin/gst-launch-1.0
# RUN gst-launch-1.0


# FFmpeg build section
RUN mkdir ~/ffmpeg_sources

RUN apt-get update && \
    apt-get -y install autoconf automake build-essential libass-dev libfreetype6-dev \
    libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev \
    libxcb-xfixes0-dev pkg-config texinfo zlib1g-dev

RUN YASM="1.3.0" && cd ~/ffmpeg_sources && \
    wget http://www.tortall.net/projects/yasm/releases/yasm-$YASM.tar.gz && \
    tar xzvf yasm-$YASM.tar.gz && \
    cd yasm-$YASM && \
    ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"  && \
    make && \
    make install && \
    make distclean

RUN VPX="v1.8.1" && cd ~/ffmpeg_sources && \
    wget https://chromium.googlesource.com/webm/libvpx/+archive/$VPX.tar.gz && \
    tar xzvf $VPX.tar.gz && \
    pwd \
    cd $VPX && \
    PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests && \
    PATH="$HOME/bin:$PATH" make && \
    make install && \
    make clean


RUN OPUS="1.3" && cd ~/ffmpeg_sources && \
    wget https://archive.mozilla.org/pub/opus/opus-$OPUS.tar.gz && \
    tar xzvf opus-$OPUS.tar.gz && \
    cd opus-$OPUS && \
    ./configure --help && \
    ./configure --prefix="$HOME/ffmpeg_build"  && \
    make && \
    make install && \
    make clean


RUN LAME="3.100" && apt-get install -y nasm  && cd ~/ffmpeg_sources && \
    wget http://downloads.sourceforge.net/project/lame/lame/$LAME/lame-$LAME.tar.gz && \
    tar xzvf lame-$LAME.tar.gz && \
    cd lame-$LAME && \
    ./configure --prefix="$HOME/ffmpeg_build" --enable-nasm --disable-shared && \
    make && \
    make install

RUN X264="20181001-2245-stable" && cd ~/ffmpeg_sources && \
    wget http://download.videolan.org/pub/x264/snapshots/x264-snapshot-$X264.tar.bz2 && \
    tar xjvf x264-snapshot-$X264.tar.bz2 && \
    cd x264-snapshot-$X264 && \
    PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static --disable-opencl --disable-asm && \
    PATH="$HOME/bin:$PATH" make && \
    make install && \
    make distclean

RUN FDK_AAC="2.0.1" && cd ~/ffmpeg_sources && \
    wget -O fdk-aac.tar.gz https://github.com/mstorsjo/fdk-aac/archive/v$FDK_AAC.tar.gz && \
    tar xzvf fdk-aac.tar.gz && \
    cd fdk-aac-$FDK_AAC && \
    autoreconf -fiv && \
    ./configure --prefix="$HOME/ffmpeg_build" --disable-shared && \
    make && \
    make install && \
    make distclean

RUN FFMPEG_VER="n4.2.1" && cd ~/ffmpeg_sources && \
    wget https://github.com/FFmpeg/FFmpeg/archive/$FFMPEG_VER.zip && \
    unzip $FFMPEG_VER.zip

RUN FFMPEG_VER="n4.2.1" && cd ~/ffmpeg_sources && \
    cd FFmpeg-$FFMPEG_VER && \
    PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
    --prefix="$HOME/ffmpeg_build" \
    --pkg-config-flags="--static" \
    --extra-cflags="-I$HOME/ffmpeg_build/include" \
    --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
    --bindir="$HOME/bin" \
    --enable-gpl \
    --enable-libass \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libtheora \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libx264 \
    --enable-nonfree \
    --enable-libxcb \
    --enable-libpulse \
    --enable-alsa && \
    PATH="$HOME/bin:$PATH" make && \
    make install && \
    make distclean && \
    hash -r && \
    mv ~/bin/ffmpeg /usr/local/bin/




# nginx-rtmp with openresty
RUN ZLIB="zlib-1.2.11" && vNGRTMP="v1.1.11" && PCRE="8.41" && nginx_build=/root/nginx && mkdir $nginx_build && \
    cd $nginx_build && \
    wget https://ftp.pcre.org/pub/pcre/pcre-$PCRE.tar.gz && \
    tar -zxf pcre-$PCRE.tar.gz && \
    cd pcre-$PCRE && \
    ./configure && make && make install && \
    cd $nginx_build && \
    wget http://zlib.net/$ZLIB.tar.gz && \
    tar -zxf $ZLIB.tar.gz && \
    cd $ZLIB && \
    ./configure && make &&  make install && \
    cd $nginx_build && \
    wget https://github.com/arut/nginx-rtmp-module/archive/$vNGRTMP.tar.gz && \
    tar zxf $vNGRTMP.tar.gz && mv nginx-rtmp-module-* nginx-rtmp-module


RUN OPENRESTY="1.13.6.2" && ZLIB="zlib-1.2.11" && PCRE="pcre-8.41" &&  openresty_build=/root/openresty && mkdir $openresty_build && \
    wget https://openresty.org/download/openresty-$OPENRESTY.tar.gz && \
    tar zxf openresty-$OPENRESTY.tar.gz && \
    cd openresty-$OPENRESTY && \
    nginx_build=/root/nginx && \
    ./configure --sbin-path=/usr/local/nginx/nginx \
    --conf-path=/usr/local/nginx/nginx.conf  \
    --pid-path=/usr/local/nginx/nginx.pid \
    --with-pcre-jit \
    --with-ipv6 \
    --with-pcre=$nginx_build/$PCRE \
    --with-zlib=$nginx_build/$ZLIB \
    --with-http_ssl_module \
    --with-stream \
    --with-mail=dynamic \
    --add-module=$nginx_build/nginx-rtmp-module && \
    make && make install && mv /usr/local/nginx/nginx /usr/local/bin




# Boringssl build section
# If you want to use the openssl instead of boringssl
# RUN apt-get update -y && apt-get install -y libssl-dev
RUN apt-get -y update && apt-get install -y --no-install-recommends \
        g++ \
        gcc \
        libc6-dev \
        make \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*
ENV GOLANG_VERSION 1.7.5
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 2e4dd6c44f0693bef4e7b46cc701513d74c3cc44f2419bf519d7868b12931ac3
RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
    && echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
    && tar -C /usr/local -xzf golang.tar.gz \
    && rm golang.tar.gz

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"



# https://boringssl.googlesource.com/boringssl/+/chromium-stable
RUN git clone https://boringssl.googlesource.com/boringssl && \
    cd boringssl && \
    git reset --hard c7db3232c397aa3feb1d474d63a1c4dd674b6349 && \
    sed -i s/" -Werror"//g CMakeLists.txt && \
    mkdir -p build  && \
    cd build  && \
    cmake -DCMAKE_CXX_FLAGS="-lrt" ..  && \
    make  && \
    cd ..  && \
    sudo mkdir -p /opt/boringssl  && \
    sudo cp -R include /opt/boringssl/  && \
    sudo mkdir -p /opt/boringssl/lib  && \
    sudo cp build/ssl/libssl.a /opt/boringssl/lib/  && \
    sudo cp build/crypto/libcrypto.a /opt/boringssl/lib/


RUN LIBWEBSOCKET="3.1.0" && wget https://github.com/warmcat/libwebsockets/archive/v$LIBWEBSOCKET.tar.gz && \
    tar xzvf v$LIBWEBSOCKET.tar.gz && \
    cd libwebsockets-$LIBWEBSOCKET && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" -DLWS_MAX_SMP=1 -DLWS_IPV6="ON" .. && \
    make && make install


RUN SRTP="2.2.0" && apt-get remove -y libsrtp0-dev && wget https://github.com/cisco/libsrtp/archive/v$SRTP.tar.gz && \
    tar xfv v$SRTP.tar.gz && \
    cd libsrtp-$SRTP && \
    ./configure --prefix=/usr --enable-openssl && \
    make shared_library && sudo make install



# March, 2019 1 commit 67807a17ce983a860804d7732aaf7d2fb56150ba
RUN apt-get remove -y libnice-dev libnice10 && \
    echo "deb http://deb.debian.org/debian  stretch-backports main" >> /etc/apt/sources.list && \
    apt-get  update && \
    apt-get install -y gtk-doc-tools libgnutls28-dev -t stretch-backports  && \
    git clone https://gitlab.freedesktop.org/libnice/libnice.git && \
    cd libnice && \
    git checkout 67807a17ce983a860804d7732aaf7d2fb56150ba && \
    bash autogen.sh && \
    ./configure --prefix=/usr && \
    make && \
    make install


RUN COTURN="4.5.0.8" && wget https://github.com/coturn/coturn/archive/$COTURN.tar.gz && \
    tar xzvf $COTURN.tar.gz && \
    cd coturn-$COTURN && \
    ./configure && \
    make && make install


# RUN GDB="8.0" && wget ftp://sourceware.org/pub/gdb/releases/gdb-$GDB.tar.gz && \
#     tar xzvf gdb-$GDB.tar.gz && \
#     cd gdb-$GDB && \
#     ./configure && \
#     make && \
#     make install


# ./configure CFLAGS="-fsanitize=address -fno-omit-frame-pointer" LDFLAGS="-lasan"


# datachannel build
RUN cd / && git clone https://github.com/sctplab/usrsctp.git && cd /usrsctp && \
    git checkout origin/master && git reset --hard 1c9c82fbe3582ed7c474ba4326e5929d12584005 && \
    ./bootstrap && \
    ./configure && \
    make && make install

WORKDIR /tmp
RUN git clone https://git.gnunet.org/libmicrohttpd.git
WORKDIR /tmp/libmicrohttpd
RUN git checkout v0.9.60
RUN autoreconf -fi
RUN ./configure
RUN make && make install



RUN cd / && git clone https://github.com/meetecho/janus-gateway.git && cd /janus-gateway && \
    git checkout refs/tags/v0.10.7 && \
    sh autogen.sh &&  \
    PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
    --enable-post-processing \
    --enable-boringssl \
    --enable-data-channels \
    --disable-rabbitmq \
    --disable-mqtt \
    --disable-unix-sockets \
    --enable-dtls-settimeout \
    --enable-plugin-echotest \
    --enable-plugin-recordplay \
    --enable-plugin-sip \
    --enable-plugin-videocall \
    --enable-plugin-voicemail \
    --enable-plugin-textroom \
    --enable-rest \
    --enable-turn-rest-api \
    --enable-plugin-audiobridge \
    --enable-plugin-nosip \
    --enable-all-handlers && \
    make && make install && make configs && ldconfig

COPY nginx.conf /usr/local/nginx/nginx.conf


ENV NVM_VERSION v0.35.3
ENV NODE_VERSION v12.18.3
ENV NVM_DIR /usr/local/nvm
RUN mkdir $NVM_DIR
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/$NVM_VERSION/install.sh | bash

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN echo "source $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default" | bash


SHELL ["/bin/bash", "-l", "-euxo", "pipefail", "-c"]
RUN node -v
RUN npm -v



CMD nginx && janus

# RUN apt-get -y install iperf iperf3
# RUN git clone https://github.com/HewlettPackard/netperf.git && \
#     cd netperf && \
#     bash autogen.sh && \
#     ./configure && \
#     make && \
#     make install

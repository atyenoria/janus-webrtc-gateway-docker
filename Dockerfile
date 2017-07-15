FROM buildpack-deps:jessie

RUN sed -i 's/archive.ubuntu.com/mirror.aarnet.edu.au\/pub\/ubuntu\/archive/g' /etc/apt/sources.list

RUN rm -rf /var/lib/apt/lists/*
RUN apt-get -y update && apt-get install -y libmicrohttpd-dev \
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
    pkg-config \
    gengetopt \
    libtool \
    automake \
    build-essential \
    subversion \
    git \
    cmake \
    unzip \
    zip \
    lsof wget vim sudo rsync cron mysql-client openssh-server supervisor locate


RUN mkdir ~/ffmpeg_sources

RUN apt-get update && \
    apt-get -y install autoconf automake build-essential libass-dev libfreetype6-dev \
    libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev \
    libxcb-xfixes0-dev pkg-config texinfo zlib1g-dev

RUN cd ~/ffmpeg_sources && \
    wget http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz && \
    tar xzvf yasm-1.3.0.tar.gz && \
    cd yasm-1.3.0 && \
    ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"  && \
    make && \
    make install && \
    make distclean

RUN cd ~/ffmpeg_sources && \
    wget http://download.videolan.org/pub/x264/snapshots/last_x264.tar.bz2 && \
    tar xjvf last_x264.tar.bz2 && \
    cd x264-snapshot* && \
    PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static --disable-opencl --disable-asm && \
    PATH="$HOME/bin:$PATH" make && \
    make install && \
    make distclean

RUN cd ~/ffmpeg_sources && \
    wget http://storage.googleapis.com/downloads.webmproject.org/releases/webm/libvpx-1.5.0.tar.bz2 && \
    tar xjvf libvpx-1.5.0.tar.bz2 && \
    cd libvpx-1.5.0 && \
    PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests && \
    PATH="$HOME/bin:$PATH" make && \
    make install && \
    make clean

RUN cd ~/ffmpeg_sources && \
    wget -O fdk-aac.tar.gz https://github.com/mstorsjo/fdk-aac/tarball/master && \
    tar xzvf fdk-aac.tar.gz && \
    cd mstorsjo-fdk-aac* && \
    autoreconf -fiv && \
    ./configure --prefix="$HOME/ffmpeg_build" --disable-shared && \
    make && \
    make install && \
    make distclean

RUN apt-get install -y nasm && \
    cd ~/ffmpeg_sources && \
    wget http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz && \
    tar xzvf lame-3.99.5.tar.gz && \
    cd lame-3.99.5 && \
    ./configure --prefix="$HOME/ffmpeg_build" --enable-nasm --disable-shared && \
    make && \
    make install && \
    make distclean

RUN cd ~/ffmpeg_sources && \
    wget http://downloads.xiph.org/releases/opus/opus-1.1.2.tar.gz && \
    tar xzvf opus-1.1.2.tar.gz && \
    cd opus-1.1.2 && \
    ./configure --prefix="$HOME/ffmpeg_build" --disable-shared && \
    make && \
    make install && \
    make clean

RUN cd / && git clone https://github.com/FFmpeg/FFmpeg.git && cd /FFmpeg && \
    ./configure --disable-yasm && \
    make && \
    make install

RUN cd ~/ffmpeg_sources && \
    wget https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
    tar xjvf ffmpeg-snapshot.tar.bz2 && \
    cd ffmpeg && \
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
    --enable-nonfree && \
    PATH="$HOME/bin:$PATH" make && \
    make install && \
    make distclean && \
    hash -r

RUN COTURN="4.5.0.6" && wget https://github.com/coturn/coturn/archive/$COTURN.tar.gz && \
    tar xzvf $COTURN.tar.gz && \
    cd coturn-$COTURN && \
    ./configure && \
    make && make install


RUN LIBWEBSOCKET="2.2.1" && vLIBWEBSOCKET="v2.2.1" && wget https://github.com/warmcat/libwebsockets/archive/$vLIBWEBSOCKET.tar.gz && \
    tar xzvf $vLIBWEBSOCKET.tar.gz && \
    cd libwebsockets-$LIBWEBSOCKET && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" -DLWS_MAX_SMP=1 -DLWS_IPV6="ON" .. && \
    make && make install


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


RUN git clone https://boringssl.googlesource.com/boringssl && \
    cd boringssl && \
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


# RUN apt-get update -y && apt-get install -y libssl-dev

# RUN apt-get -y remove libnice-dev
# RUN apt-get -y update && apt-get install -y gtk-doc-tools
# RUN LIBNICE="0.1.13" && wget https://github.com/libnice/libnice/archive/$LIBNICE.zip && \
#     unzip $LIBNICE.zip && \
#     cd libnice-$LIBNICE && \
#     sh authogen.sh && \
#     ./configure && \
#     make && \
#     make install


RUN apt-get remove -y libsrtp0-dev
RUN wget https://github.com/cisco/libsrtp/archive/v2.0.0.tar.gz && \
    tar xfv v2.0.0.tar.gz && \
    cd libsrtp-2.0.0 && \
    ./configure --prefix=/usr --enable-openssl && \
    make shared_library && sudo make install



RUN GDB="8.0" && wget ftp://sourceware.org/pub/gdb/releases/gdb-$GDB.tar.gz && \
    tar xzvf gdb-$GDB.tar.gz && \
    cd gdb-$GDB && \
    ./configure && \
    make && \
    make install


RUN cd / && git clone https://github.com/meetecho/janus-gateway.git && \
    cd janus-gateway && \
    sh autogen.sh && cd /janus-gateway && \
    git checkout origin/refcount && \
    # ./configure CFLAGS="-fsanitize=address -fno-omit-frame-pointer" LDFLAGS="-lasan"
    ./configure --enable-post-processing --enable-boringssl --disable-data-channels --disable-rabbitmq --disable-mqtt  --disable-plugin-echotest --disable-unix-sockets --enable-dtls-settimeout \
    --disable-plugin-recordplay --disable-plugin-sip --disable-plugin-videocall --disable-plugin-voicemail --disable-plugin-textroom && \
    make && make install && make configs




RUN ZLIB="zlib-1.2.11" && vNGRTMP="v1.1.11" && PCRE="8.41" && nginx_build=/root/nginx && mkdir $nginx_build && \
    cd $nginx_build && \
    wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-$PCRE.tar.gz && \
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

# RUN ZLIB="zlib-1.2.11" && NGINX="1.11.13" && nginx_build=/root/nginx && cd $nginx_build  && \
#     wget http://nginx.org/download/nginx-$NGINX.tar.gz  && \
#     tar zxf nginx-$NGINX.tar.gz && cd nginx-$NGINX && \
#     ./configure --sbin-path=/usr/local/nginx/nginx --conf-path=/usr/local/nginx/nginx.conf  --pid-path=/usr/local/nginx/nginx.pid \
#     --with-pcre=../pcre-8.39 --with-zlib=../$ZLIB  --with-http_ssl_module --with-stream --with-mail=dynamic --add-module=$nginx_build/nginx-rtmp-module && make && make install && mv /usr/local/nginx/nginx /usr/local/bin


RUN OPENRESTY="1.11.2.3" && ZLIB="zlib-1.2.11" && PCRE="pcre-8.41" &&  openresty_build=/root/openresty && mkdir $openresty_build && \
    wget https://openresty.org/download/openresty-$OPENRESTY.tar.gz && \
    tar zxf openresty-$OPENRESTY.tar.gz && \
    cd openresty-$OPENRESTY && \
    nginx_build=/root/nginx && \
    ./configure --sbin-path=/usr/local/nginx/nginx --conf-path=/usr/local/nginx/nginx.conf  --pid-path=/usr/local/nginx/nginx.pid --with-pcre-jit --with-ipv6 --with-pcre=$nginx_build/$PCRE --with-zlib=$nginx_build/$ZLIB --with-http_ssl_module --with-stream --with-mail=dynamic --add-module=$nginx_build/nginx-rtmp-module && make && make install && mv /usr/local/nginx/nginx /usr/local/bin
# FROM ubuntu:16.04
FROM ruby:2.3

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
  lsof \
  wget vim


RUN git clone https://github.com/sctplab/usrsctp && \
    cd usrsctp && \
    ./bootstrap && \
    ./configure --prefix=/usr && make && make install


RUN git clone git://git.libwebsockets.org/libwebsockets && \
    cd libwebsockets && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" .. && \
    make && make install

RUN git clone https://github.com/alanxz/rabbitmq-c && \
    cd rabbitmq-c && \
    git submodule init && \
    git submodule update && \
    autoreconf -i && \
    ./configure --prefix=/usr && make && make install


RUN apt-get install -y nginx
ADD nginx.conf /etc/nginx
ADD server.crt /
ADD server.key /


# - ./configure  PKG_CONFIG_PATH=/FFmpeg/libavcodec:/FFmpeg/libavdevice:/FFmpeg/libavfilter:/FFmpeg/libavformat:/FFmpeg/libavresample:/FFmpeg/libavutil:/FFmpeg/libpostproc:/FFmpeg/library.mak:/FFmpeg/libswresample:/FFmpeg/libswscale --prefix=/usr/local --enable-post-processing --disable-rabbitmq
#   ./configure PKG_CONFIG_PATH=./ffmpeg/libavutil:./ffmpeg/libavcodec:./ffmpeg/libswresample:./ffmpeg/libavformat --prefix=/usr/local --enable-post-processing
#   -
# RUN git clone https://github.com/meetecho/janus-gateway.git && \
#     cd janus-gateway && \
#     sh autogen.sh && \
#     ./configure --disable-websockets --disable-rabbitmq --disable-docs --prefix=/opt/janus && \
#     make && \
#     make install && \
#     make configs


RUN cd / && git clone https://github.com/FFmpeg/FFmpeg.git && cd /FFmpeg && \
    ./configure --disable-yasm && \
    make



# RUN cp -r /opt/janus/share/janus/demos/ /janus-gateway/html/
# ADD janus.plugin.streaming.cfg.sample /janus-gateway/conf
# ADD janus.transport.http.cfg.sample /janus-gateway/conf
# RUN cd janus-gateway && make configs

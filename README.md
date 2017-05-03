 # Introduction
This is a docker image for Janus Webrtc Gateway. Janus Gateway is still under active development phase. So, as the official docs says, some minor modification of the middleware library versions happens frequently. I try to deal with such a chage as much as I can. If you need any request about this repo, free to contact me.

# Characteristics
- libwebrtc 2.2.0
- libsrtp 2.0.0
- compile with the latest ref count branch for memory racing condition crash
- compile with only videoroom, audiobridge plugin
- boringssl for performance and handshake error
- nginx-rtmp-module and ffmpeg compile for MCU functionalilty experiment. For example, WEBRTC-HLS, DASH, RTMP...etc
- use --net=host for network performance. If you use docker network, some overhead might appear (ref. https://hub.docker.com/_/consul/)

# Setup
```
docker build -t atyenoria/janus-gateway-docker .
docker run --rm --net=host --name="janus" -it -P -p 443:443 -p 8088:8088 -p 8004:8004/udp -p 8004:8004 -p 8089:8089 -p 8188:8188 -t atyenoria/janus-gateway-docker /bin/bash
```

# RTMP -> RTP -> WEBRTC
```
IP=0.0.0.0
PORT=8888
/root/bin/ffmpeg -y -i  "rtmp://$IP:80/rtmp_relay/$1  live=1"  -c:v libx264 -profile:v main -s 640x480  -an -preset ultrafast  -tune zerolatency -f rtp  rtp://$IP:$PORT
```

# WEBRTC -> RTP -> RTMP
```
IP=0.0.0.0
PORT=8888
SDP_FILE=sdp.file
/root/bin/ffmpeg -analyzeduration 300M -probesize 300M -protocol_whitelist file,udp,rtp  -i $SDP_FILE  -c:v copy -c:a aac -ar 16k -ac 1 -preset ultrafast -tune zerolatency  -f flv rtmp://$IP:$PORT/rtmp_relay/atyenoria
```
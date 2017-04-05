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

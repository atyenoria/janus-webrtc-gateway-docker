
![system](https://github.com/atyenoria/janus-webrtc-gateway-docker/blob/master/system.png "system")
[![Build Status](https://travis-ci.org/atyenoria/janus-webrtc-gateway-docker.svg?branch=master)](https://travis-ci.org/atyenoria/janus-webrtc-gateway-docker)
 # Introduction
This is a docker image for Janus Webrtc Gateway. Janus Gateway is still under active development phase. So, as the official docs says, some minor modification of the middleware library versions happens frequently. I try to deal with such a chage as much as I can. If you need any request about this repo, free to contact me.

# Characteristics
- libwebsocket 2.2.0, build with LWS_MAX_SMP=1 for single thread processing
- libsrtp 2.0.0
- coturn 4.5.0.6
- openresty 1.11.2.3
- golang 1.7.5 for building boringssl
- compile with the latest ref count branch for memory racing condition crash
- compile with only videoroom, audiobridge, streaming plugin
- enable janus-pp-rec
- GDB, Address Sanitizer(optional, see Dockerfile) for getting more info when crashing
- not compile datachannel
- boringssl for performance and handshake error
- nginx-rtmp-module and ffmpeg compile for MCU functionalilty experiment. For example, WEBRTC-HLS, DASH, RTMP...etc
- use --net=host for network performance. If you use docker network, some overhead might appear (ref. https://hub.docker.com/_/consul/)

# janus ./configure

```
libsrtp version:           2.0.x
SSL/crypto library:        BoringSSL
DTLS set-timeout:          yes
DataChannels support:      no
Recordings post-processor: yes
TURN REST API client:      no
Doxygen documentation:     no
Transports:
    REST (HTTP/HTTPS):     yes
    WebSockets:            yes (new API)
    RabbitMQ:              no
    MQTT:                  no
    Unix Sockets:          no
Plugins:
    Echo Test:             no
    Streaming:             yes
    Video Call:            no
    SIP Gateway:           no
    Audio Bridge:          yes
    Video Room:            yes
    Voice Mail:            no
    Record&Play:           no
    Text Room:             no
Event handlers:
    Sample event handler:  no
```

# Setup
```
docker build --no-cache -t atyenoria/janus-gateway-docker .
docker run --rm --net=host --name="janus" -it -P -p 80:80 -p 443:443 -p 8088:8088 -p 8004:8004/udp -p 8004:8004 -p 8089:8089 -p 8188:8188 -t atyenoria/janus-gateway-docker /bin/bash
docker exec -it /bin/bash janus
```

# RTMP -> RTP -> WEBRTC
```
IP=0.0.0.0
PORT=8888
/root/bin/ffmpeg -y -i  "rtmp://$IP:80/rtmp_relay/$1  live=1"  -c:v libx264 -profile:v main -s 640x480  -an -preset ultrafast  -tune zerolatency -f rtp  rtp://$IP:$PORT
```
you should use janus streaming plugin <br>
https://github.com/meetecho/janus-gateway/blob/8b388aebb0de3ccfad3b25f940f61e48e308e604/plugins/janus_streaming.c

# WEBRTC -> RTP -> RTMP
```
IP=0.0.0.0
PORT=8888
SDP_FILE=sdp.file
/root/bin/ffmpeg -analyzeduration 300M -probesize 300M -protocol_whitelist file,udp,rtp  -i $SDP_FILE  -c:v copy -c:a aac -ar 16k -ac 1 -preset ultrafast -tune zerolatency  -f flv rtmp://$IP:$PORT/rtmp_relay/atyenoria
```
In order to get the keyframe much easier, it is useful to set  fir_freq=1 in janus conf<br>
you should use janus video room or audiobridge plugin <br>
https://github.com/meetecho/janus-gateway/blob/8b388aebb0de3ccfad3b25f940f61e48e308e604/plugins/janus_videoroom.c <br>
https://github.com/meetecho/janus-gateway/blob/8b388aebb0de3ccfad3b25f940f61e48e308e604/plugins/janus_audiobridge.c <br>
After publishing your feed in your room, you should use rtp-forward. The sample javascript command is
```
# Input this in Google Chrome debug console. you must change publisher_id, room, video_port, host, secret for your conf.
var register = { "request" : "rtp_forward", "publisher_id": 3881836128186438, "room" : 1234, "video_port": 8050, "host" : "your ip address", "secret" : "unko" }
sfutest.send({"message": register});
```


# nginx.conf
```
server_names_hash_bucket_size 64;

server {
    listen 443 ssl;
    server_name temp;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers "EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA256:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384:EDH+aRSA+AESGCM:EDH+aRSA+SHA256:EDH+aRSA:EECDH:!aNULL:!eNULL:!MEDIUM:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS:!RC4:!SEED";

    add_header Strict-Transport-Security "max-age=31536000";

    ssl_certificate /usr/local/nginx/server.crt;
    ssl_certificate_key /usr/local/nginx/server.key;

    access_log  /app/log/nginx_access.log  ;
    error_log  /app/log/nginx_error.log  debug;

    location /janus {
         proxy_set_header X-Real-IP $remote_addr;
         proxy_set_header Host $host;
         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
         proxy_set_header X-Forwarded-Proto $scheme;
         proxy_http_version 1.1;
         proxy_set_header Upgrade $http_upgrade;
         proxy_set_header Connection "upgrade";
         proxy_set_header Host $host;
         proxy_redirect off;

         proxy_pass http://127.0.0.1:8188;
     }

     location /janus_http {
     proxy_pass http://127.0.0.1:8078;
     }

    location /janus_admin {
         proxy_set_header X-Real-IP $remote_addr;
         proxy_set_header Host $host;
         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
         proxy_http_version 1.1;
         proxy_set_header Upgrade $http_upgrade;
         proxy_set_header Connection "upgrade";
         proxy_set_header Host $host;
         proxy_pass http://127.0.0.1:7188;
    }

    location /janus_admin_http {
     proxy_pass http://127.0.0.1:7088;
     }

    location /hls {
         types {
             application/vnd.apple.mpegurl m3u8;
             video/mp2t ts;
         }
         root /tmp;
         add_header Cache-Control no-cache;
     }

}

```

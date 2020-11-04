
![system](https://github.com/atyenoria/janus-webrtc-gateway-docker/blob/master/system.png "system")
[![Build Status](https://travis-ci.org/atyenoria/janus-webrtc-gateway-docker.svg?branch=master)](https://travis-ci.org/atyenoria/janus-webrtc-gateway-docker)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/1939/badge)](https://bestpractices.coreinfrastructure.org/projects/1939)

# How to use

https://www.useloom.com/share/325799006d6f4b64a6ce0662ca3f1d57

```
1. git clone https://github.com/atyenoria/janus-webrtc-gateway-docker.git && cd janus-webrtc-gateway-docker
2. make build
3. make run
4. star this repository after succeeding. Create the issue if you failed. We will help you as much as possible
```
- open in Safari (http can't work in Chrome and Firefox)
- use the host having global ip 

# Dockerfile Characteristics
- libwebsocket v3.1.0, build with LWS_MAX_SMP=1, ipv6=true for single thread processing
- libsrtp v2.2.0
- ffmpeg 4.2.1 with vpx, libx264, alsa(for headless chrome screen caputreing)
- gstreamer installation from gstreamer1.0-tools. (WIP for meson ninja build)
- coturn v4.5.0.8 in order to test turn, use iceTransportPolicy=relay https://www.w3.org/TR/webrtc/#rtcicetransportpolicy-enum 
- openresty 1.13.6.2
- nvm + node.js v12.18.3 (Latest LTS: Erbium)
- certbot for let's encyrpt ssl setting
- boringssl stable https://boringssl.googlesource.com/boringssl/+/chromium-stable 
- libnice v0.1.14 https://github.com/libnice/libnice/releases/tag/0.1.14 
- golang 1.7.5 for building boringssl
- janus v0.10.7, enable all janus plugins(like videoroom, streaming, audiobridge...etc
- [optional] GDB, Address Sanitizer(optional, see Dockerfile) for getting more info when crashing
- nginx-rtmp-module and ffmpeg compile for MCU functionalilty experiment. For example, WEBRTC-HLS, DASH, RTMP...etc
- use --net=host for network performance. If you use docker network, some overhead might appear (ref. https://hub.docker.com/_/consul/)




 # Introduction
This is a docker image for Janus Webrtc Gateway. Janus Gateway is still under active development phase. So, as the official docs says, some minor modification of the middleware library versions happens frequently. I try to deal with such a chage as much as I can. If you need any request about this repo, free to contact me. About the details of setup for this docker image, you should read the official docs https://janus.conf.meetecho.com/index.html carefully. 


# Janus WebRTC Gateway Performance 
With the latest libnice, janus gateway seems to be great performance. This repo contains this patch(see https://gitlab.freedesktop.org/libnice/libnice/merge_requests/13 )
https://webrtchacks.com/sfu-load-testing/ 
![load-test](https://github.com/atyenoria/janus-webrtc-gateway-docker/blob/master/load-test.png "load-test")
(right side janus graph is available for this docker image )

# [wip]Janus WebRTC Gateway vs Jitsi Video Bridge(Personal Opinion)
I think that janus is better for webinar(web seminar), and jitsi is better for web conference system. 
The scalability of the current Jitsi Video Bridge(20181007) is poor because of having no local recording file(I'm not sure of this..).  https://www.youtube.com/watch?v=OHHoqKCjJ0E 
Jitsi last-n + VP8 simulcasting has the very good performance for web conference https://jitsi.org/wp-content/uploads/2016/12/nossdav2015lastn.pdf 
For the video format, janus recording is per video streaming, jitsi is for mixed video conference by using chrome headlesss + ffmpeg(alsa, libxcb).
From these points, janus is suitable for webinar, jitsi is for web conference.
Of course, both WebRTC SFU are amazing work!! I'm using both.

# [wip]Network benchmarking for preparing WebRTC SFU development
use iperf, netperf

# Janus ./configure

```
libsrtp version:           2.x
SSL/crypto library:        BoringSSL
DTLS set-timeout:          yes
Mutex implementation:      GMutex (native futex on Linux)
DataChannels support:      yes
Recordings post-processor: yes
TURN REST API client:      yes
Doxygen documentation:     no
Transports:
    REST (HTTP/HTTPS):     yes
    WebSockets:            yes
    RabbitMQ:              no
    MQTT:                  no
    Unix Sockets:          no
    Nanomsg:               no
Plugins:
    Echo Test:             yes
    Streaming:             yes
    Video Call:            yes
    SIP Gateway (Sofia):   yes
    SIP Gateway (libre):   no
    NoSIP (RTP Bridge):    yes
    Audio Bridge:          yes
    Video Room:            yes
    Voice Mail:            yes
    Record&Play:           yes
    Text Room:             yes
    Lua Interpreter:       no
    Duktape Interpreter:   no
Event handlers:
    Sample event handler:  no
    RabbitMQ event handler:no
    MQTT event handler:    no
JavaScript modules:        no
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


# [wip] Mixing for janus recording
1. ffmpeg mixing from the janus recording outputs files
I think that it is very difficult to align the file from the  multiples timestamps in the case of the long mp4 file. you may consider the lipsync.
```
`#{ffmpeg_path} -y \
              -ss #{member[0].ss_at_time} -t #{member[0].t_at_time} -i #{member[0].file_path} -ss #{member[1].ss_at_time} -t #{member[1].t_at_time}  -i #{member[1].file_path} \
              -ss #{member[2].ss_at_time} -t #{member[2].t_at_time} -i #{member[2].file_path}  -f lavfi -i "color=White" \
                -filter_complex \"
                nullsrc=size=640x480 [base];
                [0:v] setpts=PTS-STARTPTS, scale=320x240 [upperleft];
                [1:v] setpts=PTS-STARTPTS, scale=320x240 [upperright];
                [2:v] setpts=PTS-STARTPTS, scale=320x240 [lowerleft];
                [3:v] setpts=PTS-STARTPTS, scale=320x240 [lowerright];
                [base][upperleft] overlay=shortest=1 [tmp1];
                [tmp1][upperright] overlay=shortest=1:x=320 [tmp2];
                [tmp2][lowerleft] overlay=shortest=1:y=240 [tmp3];
                [tmp3][lowerright] overlay=shortest=1:y=240:x=320;
                [0:a][1:a][2:a] amerge=inputs=3
              \" \
                -preset ultrafast -r 30 -b:v 300k -c:v libx264 #{"/tmp/" + @conference["room_name"] + "/" + index.to_s + ".mp4"}`
```
2. jibri's solution 
headless chrome  + grab the screen with ffmpeg is agressive approach. It is possible, but the scalabilitiy is poor. 
For example, the jibri's ffmpeg + chrome process consumes about 300% in my vps server.

# Example nginx.conf for rtp => rtmp => hls for scalablity 
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



# TODO
- [x] janus docker image
- [x] janus performance improvement patch
- [ ] jitsi vide bridge image ( in other repo)
- [ ] example app for transcording 
- [ ] demo site for RTMP -> RTP -> WEBRTC
- [ ] demo site for WEBRTC -> RTP -> RTMP
- [ ] client video mixing in janus gateway
- [ ] rtp => HLS with ffmpeg using GPU transcording 



# Project Contributor  
Akinori Nakajima
https://twitter.com/atyenori 

Anyone welcomed.

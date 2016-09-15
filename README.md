- setup
```
cd janus-base && make image && cd ../ && make run
```

- janus gateaway build error
```
postprocessiong/{ pp-webm.c, pp-h264.c } from PIX_FMT_YUV420P to AV_PIX_FMT_YUV420P
```

- docker machine create
```
docker-machine create -d virtualbox --virtualbox-cpu-count "4" --virtualbox-memory "5000"  --virtualbox-disk-size "200000" l1
```

- sync local
```
#watchman watch /Users/nakajima/akb
#watchman -- trigger /Users/nakajima/akb buildme 'data/**/*' -- /Users/jima/webrtc/docker-janus/sync.sh


rsync -av --delete /Users/jima/webrtc/docker-janus/data --exclude=video root@192.168.187.181:/root/
```


#watchman watch /Users/nakajima/akb
#watchman -- trigger /Users/nakajima/akb buildme 'data/**/*' -- /Users/jima/webrtc/docker-janus/sync.sh


rsync -av --delete /Users/jima/webrtc/docker-janus/data --exclude=video root@192.168.187.181:/root/


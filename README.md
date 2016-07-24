- postprocessiong/{ pp-webm.c, pp-h264.c }
from PIX_FMT_YUV420P to AV_PIX_FMT_YUV420P

- compile FFmpeg  on janus dir because failing linker


./configure  --with-vorbis --with-libvorbis --with-vpx --with-vorbis --with-theora --with-libogg --with-libvorbis --with-gpl --with-version3 --with-nonfree --with-postproc --with-libaacplus --with-libass --with-libcelt --with-libfaac --with-libfdk-aac --with-libfreetype --with-libmp3lame --with-libopencore-amrnb --with-libopencore-amrwb --with-libopenjpeg --with-openssl --with-libopus --with-libschroedinger --with-libspeex --with-libtheora --with-libvo-aacenc --with-libvorbis --with-libvpx --with-libx264 --with-libxvid


./configure \
  --disable-ffplay \
  --disable-ffserver \
  --disable-doc \
  --disable-htmlpages \
  --disable-podpages \
  --disable-txtpages \
  --disable-yasm --enable-gpl --enable-nonfree --enable-version3



var message = {
        request: "message" ,
        textroom: "message",
        transaction: "4231614555288251",
        room: "1234",
        text: "data"
    };

sfutest.send({"message": message});


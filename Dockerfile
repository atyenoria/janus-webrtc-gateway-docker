FROM atyenoria/janus-base

ADD file/nginx.conf /etc/nginx
ADD file/server.crt /
ADD file/server.key /


WORKDIR /app


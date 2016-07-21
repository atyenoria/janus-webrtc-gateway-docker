TEMPLATE_NAME ?= janus-base


image:
	@docker build -t atyenoria/$(TEMPLATE_NAME) .

run: image
	@docker run --rm --net=host --name="janus" -it -P -p 443:443 -p 8088:8088 -p 8004:8004/udp -p 8004:8004 -p 8089:8089 -p 8188:8188 -t atyenoria/$(TEMPLATE_NAME) /bin/bash

shell: image
	@docker run -p 0.0.0.0:7889:7889 -p 0.0.0.0:8089:8089 -a stdin -a stdout -i -t atyenoria/$(TEMPLATE_NAME) /bin/bash

image:
	@docker build -t atyenoria/$(TEMPLATE_NAME) .

stop:
	docker ps | grep janus | cut -f1 -d' ' | xargs docker stop

TEMPLATE_NAME ?= janus-webrtc-gateway-docker

build:
	@docker build -t atyenoria/$(TEMPLATE_NAME) .

build-nocache:
	@docker build --no-cache -t atyenoria/$(TEMPLATE_NAME) .

bash: 
	@docker run --rm --net=host --name="janus" -it -t atyenoria/$(TEMPLATE_NAME) /bin/bash

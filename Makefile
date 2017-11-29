TEMPLATE_NAME ?= janus-webrtc-gateway-docker

image:
	@docker build -t atyenoria/$(TEMPLATE_NAME) .

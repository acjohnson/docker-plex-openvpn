FULLTAG=registry.thejohnsons.site/docker-plex-openvpn:1.41.0.8994
DOCKERFILE=Dockerfile
all: build

build:
	docker build -t $(FULLTAG) -f $(DOCKERFILE) .

rebuild:
	docker build --no-cache -t $(FULLTAG) -f $(DOCKERFILE) .

push: build
	docker push $(FULLTAG)

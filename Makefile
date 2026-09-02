FULLTAG=registry.thejohnsons.site/docker-plex-openvpn:1.43.3.10896
DOCKERFILE=Dockerfile
all: build

build:
	docker build -t $(FULLTAG) -f $(DOCKERFILE) .

rebuild:
	docker build --no-cache -t $(FULLTAG) -f $(DOCKERFILE) .

push: build
	docker push $(FULLTAG)

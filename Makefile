-include .env
export $(shell sed 's/=.*//' .env)

.PHONY: env_var
env_var: # Print environnement variables
	@cat .env

.PHONY: env
env: # Create .env and tweak it before initialize
	cp .env.default .env

.PHONY: initialize
initialize:
	docker network create ${NGINX_PROXY_NET} || true

.PHONY: erase
erase:
	docker network rm ${NGINX_PROXY_NET} || true

.PHONY: config
config:
	docker-compose config

.PHONY: up
up:
	docker-compose up -d
	docker-compose ps

.PHONY: down
down:
	docker-compose down

.PHONY: reset
reset: down up

.PHONY: prod-up
prod-up:
	docker-compose -f docker-compose.yml up -d
	docker-compose ps

.PHONY: prod-down
prod-down:
	docker-compose -f docker-compose.yml down

.PHONY: prod-reset
prod-reset: prod-down prod-up

.PHONY: shell
shell: # Open a shell on a started container
	docker exec -it nginx-proxy /bin/bash

.PHONY: whoami
whoami:
	curl -H "Host: whoami.local" localhost:${NGINX_PROXY_HTTP}

.PHONY: whoami-up
whoami-up:
	docker-compose -f docker-compose.override.yml up -d
	docker-compose -f docker-compose.override.yml ps

.PHONY: whoami-down
whoami-down:
	docker-compose -f docker-compose.override.yml down

.PHONY: whoami-reset
whoami-reset: whoami-down whoami-up

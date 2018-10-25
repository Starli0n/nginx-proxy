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
	curl -kO https://raw.githubusercontent.com/jwilder/nginx-proxy/master/nginx.tmpl
	mkdir -p .certs
	openssl req -new -x509 -nodes -newkey rsa:2048 -keyout .certs/${NGINX_HOSTNAME}.key -out .certs/${NGINX_HOSTNAME}.crt \
		-subj "/C=FR/ST=France/L=Paris/O=Private/CN=*.${NGINX_HOSTNAME}"

.PHONY: delete-network
delete-network:
	docker network rm ${NGINX_PROXY_NET} || true

.PHONY: delete-data
delete-data: erase local-erase prod-erase

.PHONY: terminate
terminate: delete-data delete-network
	rm -f nginx.tmpl
	rm -rf .certs

.PHONY: erase
erase:
	docker-compose down --volumes

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

.PHONY: hard-reset
hard-reset: erase up

.PHONY: logs
logs: # Show logs of the services
	docker-compose logs -f

.PHONY: local-erase
local-erase:
	docker-compose -f docker-compose.local.yml down --volumes

.PHONY: local-config
local-config:
	docker-compose -f docker-compose.local.yml config

.PHONY: local-up
local-up:
	docker-compose -f docker-compose.local.yml up -d
	docker-compose -f docker-compose.local.yml ps

.PHONY: local-down
local-down:
	docker-compose -f docker-compose.local.yml down

.PHONY: local-reset
local-reset: local-down local-up

.PHONY: local-hard-reset
local-hard-reset: local-erase local-up

.PHONY: local-logs
local-logs: # Show logs of the services
	docker-compose -f docker-compose.local.yml logs -f

.PHONY: prod-erase
prod-erase:
	docker-compose -f docker-compose.yml down --volumes

.PHONY: prod-up
prod-up:
	docker-compose -f docker-compose.yml up -d
	docker-compose -f docker-compose.yml ps

.PHONY: prod-down
prod-down:
	docker-compose -f docker-compose.yml down

.PHONY: prod-reset
prod-reset: prod-down prod-up

.PHONY: prod-hard-reset
prod-hard-reset: prod-erase prod-up

.PHONY: prod-logs
prod-logs: # Show logs of the services
	docker-compose -f docker-compose.yml logs -f

.PHONY: shell
shell: # Open a shell on a started container
	docker exec -it nginx /bin/bash

.PHONY: shell-proxy
shell-proxy: # Open a shell on a started container
	docker exec -it nginx-proxy /bin/bash

.PHONY: shell-gen
shell-gen: # Open a shell on a started container
	docker exec -it nginx-gen /bin/bash

.PHONY: shell-letsencrypt
shell-letsencrypt: # Open a shell on a started container
	docker exec -it nginx-letsencrypt /bin/bash

.PHONY: force-renew
force-renew:
	docker exec nginx-letsencrypt /app/force_renew

.PHONY: cert-status
cert-status:
	docker exec nginx-letsencrypt /app/cert_status

.PHONY: whoami
whoami:
	curl -H "Host: whoami.${NGINX_HOSTNAME}" localhost:${NGINX_PROXY_HTTP}

.PHONY: whoami-config
whoami-config:
	docker-compose -f docker-compose.override.yml config

.PHONY: whoami-up
whoami-up:
	docker-compose -f docker-compose.override.yml up -d
	docker-compose -f docker-compose.override.yml ps

.PHONY: whoami-down
whoami-down:
	docker-compose -f docker-compose.override.yml down

.PHONY: whoami-reset
whoami-reset: whoami-down whoami-up

.PHONY: whoami-url
whoami-url:
	@echo http://whoami.${NGINX_HOSTNAME}:${NGINX_PROXY_HTTP}

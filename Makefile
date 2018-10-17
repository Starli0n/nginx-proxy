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

.PHONY: delete-network
delete-network:
	docker network rm ${NGINX_PROXY_NET} || true

.PHONY: delete-data
delete-data:
	docker-compose down --volumes

.PHONY: delete
delete: delete-data delete-network
	rm -f nginx.tmpl

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

.PHONY: reset-hard
reset-hard: delete-data up

.PHONY: logs
logs: # Show logs of the services
	docker-compose logs -f

.PHONY: prod-delete-data
prod-delete-data:
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

.PHONY: prod-reset-hard
prod-reset-hard: prod-delete-data prod-up

.PHONY: prod-logs
prod-logs: # Show logs of the services
	docker-compose -f docker-compose.yml logs -f

.PHONY: shell
shell: # Open a shell on a started container
	docker exec -it nginx /bin/bash

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

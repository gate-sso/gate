.PHONY: all
CMD=openssl genrsa -des3 -passout pass:x -out /tmp/server.pass.key 2048 && \
    openssl rsa -passin pass:x -in /tmp/server.pass.key -out /tmp/server.key && \
    rm /tmp/server.pass.key && \
    openssl req -new -key /tmp/server.key -out /tmp/server.csr -subj "/C=UK/ST=Warwickshire/L=Leamington/O=Test/OU=Example/CN=test-example.com" && \
    openssl x509 -req -days 1 -in /tmp/server.csr -signkey /tmp/server.key -out /tmp/server.crt && cat /tmp/server.crt

all: build run db_setup

init:
	cp -n .env.sample .env || true
	@echo "\nPlease update you .env file with proper values."

build:
	@echo "\nBuilding gate\n"
	docker-compose build

run:
	@echo "\nDaemonising docker compose\n"
	rm -f tmp/pids/server.pid
	docker-compose up -d

db_setup:
	@echo "\nSetting up database\n"
	docker-compose run --rm web rake db:setup

migrate:
	@echo "\nRunning migrations\n"
	docker-compose run --rm web rake db:migrate

rc:
	@echo "\nBooting rails console\n"
	docker-compose run web rails console

kill:
	@echo "\nRemoving daemonised containers\n"
	docker-compose kill
	docker ps | grep gate_web | awk '{ print $$1 }' | xargs -I{} docker kill {}
	docker ps -a | grep "gate" | awk '{print $1}' | xargs -I{} docker rm {}

logs:
	@echo "\nGetting logs of web container\n"
	docker-compose logs -f web

attach:
	@echo "\nAttaching to gate web container\n"
	docker attach gate_web_1

shell:
	@echo "\n Shell Access to App server\n"
	docker-compose exec -it web /bin/bash

routes:
	@echo "\nListing routes\n"
	docker-compose run --rm web rake routes

rspec:
	docker-compose run --rm -e RAILS_ENV=test -e DB_NAME=gate_test web rake db:drop db:create db:migrate
	docker-compose run --rm \
	-e RAILS_ENV=test \
    -e DB_NAME=gate_test \
    web bash -c "${CMD} && env && rspec $(filter-out $@,$(MAKECMDGOALS))"


%:
    @:

.PHONY: all

all: build run db_setup

init:
	cp -n .env.sample .env || true
	@echo "\nPlease update you .env file with proper values."

build:
	@echo "\nBuilding gate\n"
	docker-compose build

run:
	@echo "\nDaemonising docker compose\n"
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

attach:
	@echo "\nAttaching to gate web container\n"
	docker attach gate_web_1

rspec:
	docker-compose run --rm web rake db:migrate:reset
	docker-compose run --rm web rspec

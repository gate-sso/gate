.PHONY: all

all: init build run

init:
	cp -n .env.sample .env || true
	@echo "\nPlease update you .env file with proper values."

build:
	@echo "\nBuilding gate\n"
	docker-compose build

run:
	@echo "\nDaemonising docker compose\n"
	docker-compose up -d
	@echo "\nSetting up database\n"
	docker-compose run --rm web rake db:setup

kill:
	@echo "\nRemoving daemonised containers\n"
	docker-compose kill

attach:
	@echo "\nAttaching to gate web container\n"
	docker attach gate_web_1

rspec:
	docker-compose run --rm web rspec

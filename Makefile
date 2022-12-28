
start-development:
	# set env
	cd docker/development/ && cp -f development.env .env
	# start
	cd docker/development/ && docker-compose up -d

stop-development:
	cd docker/development/ && docker-compose stop

create-network:
	docker network create django

start-production:
	# set env
	cd docker/production/ && cp -f production.env .env
	# start
	cd docker/production/ && docker-compose up -d

stop-production:
	cd docker/production/ && docker-compose stop

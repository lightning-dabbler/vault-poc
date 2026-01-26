.DEFAULT_GOAL := help
UV_VERSION := 0.9.12

help: # generate make help
	@grep -E '^[a-zA-Z_-]+:.*?#+.*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?#+"}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: # build vault-poc docker image (args=?)
	docker build -f docker/vault/Dockerfile -t vault-poc $(args) .

build-no-cache: # build vault-poc docker image ([no cache] args=?)
	docker build -f docker/vault/Dockerfile -t vault-poc --no-cache $(args) .

build-diagrams: # Build vault-poc-diagrams docker image (args=?)
	docker build -f docker/diagrams/Dockerfile -t vault-poc-diagrams --build-arg "UV_VERSION=$(UV_VERSION)" .

build-diagrams-no-cache: # build vault-poc-diagrams docker image ([no cache] args=?)
	docker build -f docker/diagrams/Dockerfile -t vault-poc --no-cache --build-arg "UV_VERSION=$(UV_VERSION)" .

pre-commit: # Run pre-commit validations on all files
	pre-commit run --all-files

init-pre-commit: # Initialize pre-commit
	pre-commit install

py-format: # use ruff to format and lint configured python files in project
	uv run --group lint ruff check --config ruff.toml --fix
	uv run --group lint ruff format --config ruff.toml

enter-diagrams: # spin up vault-diagrams docker container and shell into it
	docker-compose -p vault -f docker-compose/vault-diagrams.yml --project-directory . up -d
	docker exec -it vault-diagrams bash

down-diagrams: # stop and kill vault-diagrams and vault-diagrams-network network
	docker-compose -p vault --project-directory . -f docker-compose/vault-diagrams.yml down

up: # Spin up vault-transit-raft docker containers
	docker-compose -p vault-transit-raft --project-directory . -f docker-compose/vault-transit-raft.yml up -d

down: # Spin down vault-transit-raft docker containers
	docker-compose -p vault-transit-raft --project-directory . -f docker-compose/vault-transit-raft.yml down

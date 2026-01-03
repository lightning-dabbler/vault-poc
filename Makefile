.DEFAULT_GOAL := help

help: # generate make help
	@grep -E '^[a-zA-Z_-]+:.*?#+.*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?#+"}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: # build vault-poc docker image (args=?)
	docker build -f Dockerfile -t vault-poc $(args) .

build-no-cache: # build vault-poc docker image ([no cache] args=?)
	docker build -f Dockerfile -t vault-poc --no-cache $(args) .

pre-commit: # Run pre-commit validations on all files
	pre-commit run --all-files

init-pre-commit: # Initialize pre-commit
	pre-commit install

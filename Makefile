-include env_make

MAKEFLAGS += --warn-undefined-variables
.DEFAULT_GOAL := build
.PHONY: *

# we get these from CI environment if available, otherwise from git
GIT_COMMIT ?= $(shell git rev-parse --short HEAD)
GIT_BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD)
WORKSPACE ?= $(shell pwd)

namespace ?= anaxexp
tag := branch-$(shell basename $(GIT_BRANCH))
image := $(namespace)/nginx
example := $(namespace)/nginx-example
backend := $(namespace)/nginx-backend
testImage := $(namespace)/nginx-testrunner

NGINX_VER ?= 1.15.2

NGINX_MINOR_VER ?= $(shell echo "${NGINX_VER}" | grep -oE '^[0-9]+\.[0-9]+')
TAG ?= $(NGINX_MINOR_VER)

REPO = $(namespace)/nginx
NAME = nginx-$(NGINX_MINOR_VER)

ifneq ($(STABILITY_TAG),)
    ifneq ($(TAG),latest)
        override TAG := $(TAG)-$(STABILITY_TAG)
    endif
endif


## Display this help message
help:
	@awk '/^##.*$$/,/[a-zA-Z_-]+:/' $(MAKEFILE_LIST) | awk '!(NR%2){print $$0p}{p=$$0}' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' | sort


build:
	docker build -t $(REPO):$(TAG) --build-arg NGINX_VER=$(NGINX_VER) ./

## Builds the application example images
build/examples: build
	sed 's/latest/$(tag)/' examples/Dockerfile > examples/Examplefile
	cd ./examples && docker build -f Examplefile -t=$(example):$(tag) .
	cd ./examples/backend && docker build -t=$(backend):$(tag) .

## Build the test running container
build/tester:
	docker build -f test/Dockerfile -t=$(testImage):$(tag) .



push:
	docker push $(REPO):$(TAG)

## Push the current example application container images to the Docker Hub
push/examples:
	docker push $(example):$(tag)
	docker push $(backend):$(tag)
	docker push $(testImage):$(tag)

## Tag the current images as 'latest' and push them to the Docker Hub
ship:
	docker tag $(image):$(tag) $(image):latest
	docker tag $(image):$(tag) $(image):latest
	docker push $(image):$(tag)
	docker push $(image):latest

# ------------------------------------------------
# Test running

## Pull the container images from the Docker Hub
pull:
	docker pull $(image):$(tag)

## Pull the test target images from the docker Hub
pull/examples:
	docker pull $(example):$(tag)
	docker pull $(backend):$(tag)

## Run the example via Docker Compose against the local Docker environment
run/compose:
	cd ./examples/compose && TAG=$(tag) docker-compose -p nginx up -d

## Run the example via triton-compose on Joyent's Triton
run/anaxexp:
	cd ./examples/anaxexp && TAG=$(tag) anaxexp-compose -p nginx up -d

test:
	cd ./tests/basic && IMAGE=$(REPO):$(TAG) ./run.sh
	cd ./tests/wordpress && IMAGE=$(REPO):$(TAG) ./run.sh

## Run the integration test runner against Compose locally.
test/compose:
	docker run --rm \
		-e TAG=$(tag) \
		-e GIT_BRANCH=$(GIT_BRANCH) \
		--network=bridge \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-w /src \
		$(testImage):$(tag) /src/compose.sh

## Run the integration test runner. Runs locally but targets Triton.
test/triton:
	$(call check_var, ANAXEXP_PROFILE, \
		required to run integration tests on AnaxExp.)
	docker run --rm \
		-e TAG=$(tag) \
		-e TRITON_PROFILE=$(ANAXEXP_PROFILE) \
		-e GIT_BRANCH=$(GIT_BRANCH) \
		-v ~/.ssh:/root/.ssh:ro \
		-v ~/.anaxexp/profiles.d:/root/.anaxexp/profiles.d:ro \
		-w /src \
		$(testImage):$(tag) /src/anaxexp.sh

# runs the integration test above but entirely within your local
# development environment rather than the clean test rig
test/anaxexp/dev:
	./test/anaxexp.sh

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) /bin/bash

run:
	docker run --rm --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) $(CMD)

start:
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG)

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	-docker rm -f $(NAME)

release: build push

## Print environment for build debugging
debug:
	@echo WORKSPACE=$(WORKSPACE)
	@echo GIT_COMMIT=$(GIT_COMMIT)
	@echo GIT_BRANCH=$(GIT_BRANCH)
	@echo ANAXEXP_PROFILE=$(TRITON_PROFILE)
	@echo namespace=$(namespace)
	@echo tag=$(tag)
	@echo image=$(image)
	@echo testImage=$(testImage)

check_var = $(foreach 1,$1,$(__check_var))
__check_var = $(if $(value $1),,\
	$(error Missing $1 $(if $(value 2),$(strip $2))))
SHELL := /bin/bash

CUDA_ARCHITECTURES := "75"
DATA_PATH := $(shell pwd)/data

# echo in green
define echo_green
	@echo -e "\033[32m$1\033[0m"
endef

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help


.PHONY: build-docker
build-docker: ## Build docker image. Use CUDA_ARCHITECTURES to specify the CUDA architectures to build for.
	$(call echo_green,"Building docker image...")
	@echo "CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES}"
	@docker build -t="colmap:latest" --build-arg CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES} ./

.PHONY: run-gui
run-gui: build-docker ## Run docker image with GUI support. Use DATA_PATH to specify the path to the data folder.
	$(call echo_green,"Running docker image with GUI support...")
	@docker run \
		-e QT_XCB_GL_INTEGRATION=xcb_egl \
		-e DISPLAY \
		-e XAUTHORITY \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v $(shell pwd):/workspace/colmap \
		-w /workspace/colmap \
		--gpus all \
		--privileged \
		-it colmap:latest \
		colmap gui

.PHONY: run
run: build-docker ## Run docker image. Use DATA_PATH to specify the path to the data folder.
	$(call echo_green,"Running docker image...")
	@docker run \
		--gpus all \
		-w /workspace/colmap \
		-v $(shell pwd):/workspace/colmap \
		--privileged \
		-it colmap:latest \

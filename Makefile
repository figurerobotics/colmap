SHELL := /bin/bash

CUDA_ARCHITECTURES := "75"

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
run-gui: build-docker ## Run docker image with GUI support. PWD will be mounted to /workspace/colmap and /data to /data.
	$(call echo_green,"Running docker image with GUI support...")
	@docker run \
		--gpus all \
		--mount source=colmap-bashhistory,target=/commandhistory,type=volume \
		--privileged \
		-e DISPLAY \
		-e QT_XCB_GL_INTEGRATION=xcb_egl \
		-e XAUTHORITY \
		-v /data:/data \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v $(shell pwd):/workspace/colmap \
		-w /workspace/colmap \
		--rm \
		-it colmap:latest \
		colmap gui

.PHONY: run-term
run-term: build-docker ## Run docker image with terminal. PWD will be mounted to /workspace/colmap and /data to /data.
	$(call echo_green,"Running docker image...")
	@docker run \
		--gpus all \
		--mount source=colmap-bashhistory,target=/commandhistory,type=volume \
		--privileged \
		-v /data:/data \
		-v $(shell pwd):/workspace/colmap \
		-w /workspace/colmap \
		--rm \
		-it colmap:latest \
		bash

.PHONY: run
run: build-docker ## Run colmap command in docker image. PWD will be mounted to /workspace/colmap and /data to /data.
	$(call echo_green,"Running docker image...")
	@docker run \
		--gpus all \
		--mount source=colmap-bashhistory,target=/commandhistory,type=volume \
		--privileged \
		-v /data:/data \
		-v $(shell pwd):/workspace/colmap \
		-w /workspace/colmap \
		--rm \
		colmap:latest \
		colmap ${ARGS}
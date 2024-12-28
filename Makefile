################################################################################################
# Project's Makefile
#
# This Makefile is split into the following sections:
#   - Requirements: prerequisites for running the environment.
#   - Application: for building, testing, and publishing the project.
#   - Development: for formatting, linting, and other development tasks.
#   - Containerisation: for building, testing, and publishing the Docker image that is used to run the project.
#   - Deployment: for deploying the project to a specific environment.
#
# We write our rule names in the following format: [verb]-[noun]-[noun], e.g. "build-jars".
#
# Variables ####################################################################################

UID=$(shell id -u)
GID=$(shell id -g)

SHELL:=/bin/bash
PROJECT_ROOT:=$(CURDIR)

VERSION?=DEV-SNAPSHOT

SKD_JAVA_VERSION=21-tem
SDK_GRADLE_VERSION=8.11

APP_NAME=outai-sandbox-java
APP_JAR_LOCATION=$(PROJECT_ROOT)/build/libs/$(APP_NAME)-$(VERSION).jar
APP_PORT?=8080

IMAGE_ID=$(APP_NAME):$(VERSION)
IMAGE_SAVE_LOCATION?=$(PROJECT_ROOT)/build/images
IMAGE_PROJECT_ROOT=/home/gradle/app

HOST_GRADLE_DATA?=$(HOME)/.gradle
HOST_MAVEN_DATA?=$(HOME)/.m2

GW:=$(PROJECT_ROOT)/gradlew
SDKMAN_INIT:=export SDKMAN_DIR="$(HOME)/.sdkman"; \
             [ -s "$(HOME)/.sdkman/bin/sdkman-init.sh" ] \
             && source "$(HOME)/.sdkman/bin/sdkman-init.sh"

# Requirements ##################################################################################

.PHONY: require-docker
require-docker:
	@command -v docker >/dev/null 2>&1 || \
	(echo "Docker is required. Please install via https://docs.docker.com/engine/install/." && exit 1)

.PHONY: require-sdkman
require-sdkman:
	@$(SDKMAN_INIT); command -v sdk >/dev/null 2>&1 || \
	(echo "Sdkman is required. Please install via 'make install-sdkman'." && exit 1)

.PHONY: require-gradle
require-gradle:
	@command -v gradle >/dev/null 2>&1 || \
	(echo "Gradle is required. Please install via 'make install-gradle'." && exit 1)

.PHONY: require-java
require-java:
	@if ! java -version 2>&1 | grep '\"21\"' >/dev/null 2>&1; then \
		echo "Java 21 in path is required. Please set/install via 'make install-java'."; \
		exit 1; \
	fi

.PHONY: install-sdkman
install-sdkman:
	@echo "Installing Sdkman..."
	@curl -s "https://get.sdkman.io" | bash

.PHONY: install-gradle
install-gradle: require-sdkman
	@echo "Installing Gradle..."
	@$(SDKMAN_INIT); sdk install gradle $(SDK_GRADLE_VERSION) -d < /dev/null

.PHONY: install-java
install-java: require-sdkman
	@echo "Installing Java 21..."
	@$(SDKMAN_INIT); sdk install java $(SKD_JAVA_VERSION) -d < /dev/null

# Application ##################################################################################

.PHONY: build-app
build-app:
	@echo "******** Building the application... ********"
	VERSION=$(VERSION) $(GW) build -x test --info

.PHONY: test-app
test-app:
	@echo "******** Testing application... ********"
	VERSION=$(VERSION) $(GW) test --info

# Development ##################################################################################

.PHONY: check-lint
check-lint:
	@echo "******** Linting the code... ********"
	$(GW) sonarlintMain
	$(GW) sonarlintTest

.PHONY: check-format
check-format:
	@echo "******** Checking the code format... ********"
	$(GW) spotlessCheck

.PHONY: format-code
format-code:
	@echo "******** Formatting the code... ********"
	$(GW) spotlessApply

# Containerisation ##############################################################################

define build_docker_image
	@echo "Building Docker image..."
	docker build \
	    --build-arg APP_VERSION=$(VERSION) \
	    --build-arg APP_NAME=$(APP_NAME) \
	    --build-arg USER_UID=$(UID) \
	    --build-arg USER_GID=$(GID) \
	    -t $(IMAGE_ID) .
endef

define run_docker_dev_mount
	@docker run $(2) \
	    --user $(UID):$(GID) \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(HOST_GRADLE_DATA):/home/gradle/.gradle \
		-v $(HOST_MAVEN_DATA):/home/gradle/.m2 \
		-v $(PROJECT_ROOT)/src:$(IMAGE_PROJECT_ROOT)/src \
		-v $(PROJECT_ROOT)/build:$(IMAGE_PROJECT_ROOT)/build \
		-v $(PROJECT_ROOT)/.gradle:$(IMAGE_PROJECT_ROOT)/.gradle \
		-v $(PROJECT_ROOT)/gradle:$(IMAGE_PROJECT_ROOT)/gradle \
		-v $(PROJECT_ROOT)/gradlew:$(IMAGE_PROJECT_ROOT)/gradlew \
		-v $(PROJECT_ROOT)/build.gradle.kts:$(IMAGE_PROJECT_ROOT)/build.gradle.kts \
		-v $(PROJECT_ROOT)/settings.gradle.kts:$(IMAGE_PROJECT_ROOT)/settings.gradle.kts \
		--rm --name $(APP_NAME)-toolchain-dev $(IMAGE_ID) $(1)
endef

.PHONY: check-test-docker
check-test-docker: require-docker
	@echo "Testing application... (Containerised)"
	@$(call build_docker_image)
	@$(call run_docker_dev_mount,./gradlew test --info)

.PHONY: check-format-docker
check-format-docker: require-docker
	@echo "Checking application formatting... (Containerised)"
	@$(call build_docker_image)
	@$(call run_docker_dev_mount,./gradlew spotlessCheck)

.PHONY: check-lint-docker
check-lint-docker: require-docker
	@echo "Checking application linting... (Containerised)"
	@$(call build_docker_image)
	@$(call run_docker_dev_mount,./gradlew sonarlintMain sonarlintTest)

.PHONY: check-code-quality-docker
check-code-quality-docker: require-docker
	@echo "Checking application code quality... (Containerised)"
	@$(MAKE) check-format-docker
	@$(MAKE) check-lint-docker
	@$(MAKE) check-test-docker

.PHONY: login-into-container
login-into-container:
	@echo "Logging into the container..."
	$(call build_docker_image)
	@$(call run_docker_dev_mount,/bin/bash -li,--tty --interactive)

# Deployment ####################################################################################

.PHONY: new-task
new-task:
	@echo "******** Committing and pushing everything before moving on... ********"
	if [ "$(shell git branch --show-current)" != "main" ]; then \
		git add . && git commit -m "complete: final changes" && git push; \
	fi
	@echo "******** Creating a new task branch... ********"
	DATE=$$(date +'%y-%m-%d'); \
	TASK_NUMBER=$$(git branch --list "$$DATE/T*" | wc -l); \
	TASK_NUMBER=$$((TASK_NUMBER + 1)); \
	BRANCH_NAME=$$DATE/T$$TASK_NUMBER; \
	git checkout main && git checkout -b $$BRANCH_NAME

.PHONY: bundle
bundle:
	@echo "******** Bundling the project (ZIP)... ********"
	mkdir -p $(PROJECT_ROOT)/build
	rm -f $(PROJECT_ROOT)/build/outai-task-artifact.zip
	cd $(PROJECT_ROOT) && \
	zip -r $(PROJECT_ROOT)/build/outai-task-artifact.zip . \
		-x './.gradle/*' -x './.idea/*' -x './.git/*' -x './build/*' -x './.kotlin/*'

.PHONY: unbundle-in-sphere
unbundle-in-sphere:
	echo "******** Unbundling the project (ZIP) in Sphere IDE... ********"
	mkdir -p ../tmp
	mv outai-task-artifact.zip ../tmp
	rm -rf *
	mv ../tmp/outai-task-artifact.zip .
	unzip -o outai-task-artifact.zip -d .

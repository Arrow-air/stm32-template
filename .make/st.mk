BUILD_IMAGE_NAME     ?= arrow-stm32
BUILD_IMAGE_TAG      ?= latest
OUTPUTS_PATH        ?= $(SOURCE_PATH)/out
ADDITIONAL_OPT      ?=

build_run = docker run \
	--name=$(BUILD_IMAGE_NAME)-$@ \
	--rm \
	--user `id -u`:`id -g` \
	--workdir=/usr/src/app/ \
	--env-file=$(SOURCE_PATH)/.env \
	$(ADDITIONAL_OPT) \
	-v "$(SOURCE_PATH)/:/usr/src/app/" \
	-t $(BUILD_IMAGE_NAME):$(BUILD_IMAGE_TAG) \
	/bin/bash -c "$(1)"

build-docker-pull:
	@echo docker pull -q $(BUILD_IMAGE_NAME):$(BUILD_IMAGE_TAG)

.help-build:
	@echo ""
	@echo "$(SMUL)$(BOLD)$(GREEN)Build Container$(SGR0)"
	@echo "  $(BOLD)build$(SGR0)       -- Run 'cmake'"

.SILENT: build-docker-pull

build: build-docker-pull
	@echo "$(CYAN)Running cmake...$(SGR0)"
	mkdir -p build
	@$(call build_run,cmake -S. -Bbuild/)
	@$(call build_run,cd build && make $(PROJECT_NAME))

flash: build-docker-pull
	@echo "$(CYAN)Flashing...$(SGR0)"
	mkdir -p build
	@$(call build_run,cmake -S. -Bbuild/)
	@$(call build_run,cd build && make $(PROJECT_NAME))

all: release

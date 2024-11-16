# This Makefile is used for dev purposes
# Variables
REPO := ghcr.io/bnema/go-helloworld-http
TAG := latest
DIST_DIR := ./dist
ENGINE := podman
BIN := go-helloworld-http

# Architectures
ARCHS := amd64 arm64

# Phony targets
.PHONY: all build build-push clean

# Default target
all: build

# Build binaries
build:
	@echo "Building Go binaries..."
	@mkdir -p $(DIST_DIR)
	@rm -f $(DIST_DIR)/*
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o $(DIST_DIR)/$(BIN)-linux-amd64 ./main.go
	@CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o $(DIST_DIR)/$(BIN)-linux-arm64 ./main.go
	@echo "Go binaries built successfully"

# Build and push Docker images
build-push: build
	@echo "Cleaning up dangling images..."
	@$(ENGINE) image prune -f

	@echo "Building and pushing Docker images..."
	@for arch in $(ARCHS); do \
		cp $(DIST_DIR)/$(BIN)-linux-$$arch $(BIN); \
		$(ENGINE) build -t $(REPO):$(TAG)-$$arch .; \
		rm $(BIN); \
		$(ENGINE) push $(REPO):$(TAG)-$$arch; \
	done

	@echo "Removing existing manifest..."
	@$(ENGINE) manifest rm $(REPO):$(TAG) || true

	@echo "Creating multi-arch manifest..."
	@$(ENGINE) manifest create --amend $(REPO):$(TAG) \
		$(REPO):$(TAG)-amd64 \
		$(REPO):$(TAG)-arm64

	@echo "Annotating architectures..."
	@$(ENGINE) manifest annotate $(REPO):$(TAG) \
		$(REPO):$(TAG)-amd64 --arch amd64
	@$(ENGINE) manifest annotate $(REPO):$(TAG) \
		$(REPO):$(TAG)-arm64 --arch arm64 --variant v8

	@echo "Pushing multi-arch manifest..."
	@$(ENGINE) manifest push --all $(REPO):$(TAG)

	@echo "Cleaning up local manifest..."
	@$(ENGINE) manifest rm $(REPO):$(TAG) || true

	@echo "Script completed successfully."

# Clean up
clean:
	@echo "Cleaning up..."
	@rm -rf $(DIST_DIR)
	@$(ENGINE) system prune -f
	@echo "Cleanup completed."

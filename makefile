# Makefile for installing and uninstalling the POXI script

# Script details
SCRIPT_NAME := poxi
SCRIPT_DIR := $(CURDIR)
SRC_DIR := $(SCRIPT_DIR)/src
MAIN_SCRIPT := $(SCRIPT_DIR)/poxi
UTILS_SCRIPT := $(SRC_DIR)/utils.sh

# Installation details
PREFIX := /usr/local
BIN_DIR := $(PREFIX)/bin
SCRIPT_INSTALL_DIR := $(PREFIX)/share/$(SCRIPT_NAME)

# Check if the script is already installed
IS_INSTALLED := $(shell command -v $(SCRIPT_NAME) > /dev/null && echo "yes" || echo "no")

# Default target
.DEFAULT_GOAL := all

all: help

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  install       Install $(SCRIPT_NAME) to $(BIN_DIR) and required files to $(SCRIPT_INSTALL_DIR)"
	@echo "  uninstall     Uninstall $(SCRIPT_NAME) from the system"
	@echo "  clean         Remove any build artifacts (none in this case)"
	@echo "  help          Show this help message"

install: check_root check_prerequisites create_install_dir copy_files create_symlink
	@echo "$(SCRIPT_NAME) installed successfully to $(BIN_DIR)"

uninstall: check_root remove_symlink remove_install_dir
	@echo "$(SCRIPT_NAME) uninstalled successfully"

clean:
	@echo "Nothing to clean"

check_root:
	@if [ "$(shell whoami)" != "root" ]; then \
		echo "Error: This operation requires root privileges. Use sudo."; \
		exit 1; \
	fi

check_prerequisites:
	@echo "Checking prerequisites..."
	@if ! command -v jq &> /dev/null; then \
        echo "Error: jq is required. Please install it and try again."; \
        exit 1; \
    fi
	@if ! command -v fzf &> /dev/null; then \
        echo "Error: fzf is required. Please install it and try again."; \
        exit 1; \
    fi
	@echo "Prerequisites met."

create_install_dir:
	@echo "Creating install directory: $(SCRIPT_INSTALL_DIR)"
	@mkdir -p $(SCRIPT_INSTALL_DIR)
	@mkdir -p $(BIN_DIR)

copy_files:
	@echo "Copying files to $(SCRIPT_INSTALL_DIR)"
	@cp -r $(SRC_DIR) $(SCRIPT_INSTALL_DIR)/
	@cp $(MAIN_SCRIPT) $(SCRIPT_INSTALL_DIR)/
	@cp $(SCRIPT_DIR)/packages.json $(SCRIPT_INSTALL_DIR)/

create_symlink:
	@echo "Creating symlink: $(BIN_DIR)/$(SCRIPT_NAME) -> $(SCRIPT_INSTALL_DIR)/main.sh"
	@if [ "$(IS_INSTALLED)" == "yes" ]; then \
        echo "Warning: $(SCRIPT_NAME) is already installed. Overwriting..."; \
		rm -f $(BIN_DIR)/$(SCRIPT_NAME); \
    fi
	@ln -s $(SCRIPT_INSTALL_DIR)/main.sh $(BIN_DIR)/$(SCRIPT_NAME)

remove_symlink:
	@echo "Removing symlink: $(BIN_DIR)/$(SCRIPT_NAME)"
	@rm -f $(BIN_DIR)/$(SCRIPT_NAME)

remove_install_dir:
	@echo "Removing install directory: $(SCRIPT_INSTALL_DIR)"
	@rm -rf $(SCRIPT_INSTALL_DIR)

.PHONY: all help install uninstall clean check_root check_prerequisites create_install_dir copy_files create_symlink remove_symlink remove_install_dir


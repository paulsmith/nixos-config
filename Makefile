HOSTNAME ?= $(shell hostname)
UNAME := $(shell uname)

switch:
ifeq ($(UNAME), Darwin)
	sudo darwin-rebuild switch --flake ".#${HOSTNAME}"
else
	sudo nixos-rebuild switch --flake ".#$(HOSTNAME)"
endif

test:
	@echo "test TBD"

update:
	nix flake update

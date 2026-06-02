HOSTNAME ?= $(shell hostname)
UNAME := $(shell uname)

VM_HOST ?= nixos-vm
VM_USER ?= paul
VM_SSH_HOST ?= 2222
VM_DISK ?= ./.var/$(VM_HOST).qcow2

.PHONY: vm-build vm-run vm-ssh

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

vm-build:
	nix build .#nixosConfigurations.$(VM_HOST).config.system.build.vm

vm-run: vm-build
	mkdir -p .var
	NIX_DISK_IMAGE="$(VM_DISK)" \
	QEMU_NET_OPTS="hostfwd=tcp::$(VM_SSH_HOST)-:22" \
	QEMU_KERNEL_PARAMS="console=ttyAMA0" \
	./result/bin/run-$(VM_HOST)-vm -nographic

vm-ssh:
	ssh -p $(VM_SSH_HOST) $(VM_USER)@localhost

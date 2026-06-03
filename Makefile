HOSTNAME ?= $(shell hostname)
UNAME := $(shell uname)

VM_HOST ?= nixos-vm
VM_USER ?= paul
VM_SSH_HOST ?= 2222
VM_SSH_TARGET ?= $(VM_USER)@localhost
VM_STATE_DIR ?= ./.var
VM_STATE_DIR_ABS := $(abspath $(VM_STATE_DIR))
VM_SSH_KEY ?= $(VM_STATE_DIR_ABS)/$(VM_HOST)_ed25519
VM_SSH_KNOWN_HOSTS ?= $(VM_STATE_DIR_ABS)/known_hosts
VM_SSH_HOST_KEY_OPTS ?= -o UserKnownHostsFile=$(VM_SSH_KNOWN_HOSTS) -o StrictHostKeyChecking=accept-new
VM_SSH_IDENTITY_OPTS ?= -i $(VM_SSH_KEY) -o IdentitiesOnly=yes -o IdentityAgent=none
VM_SSH_OPTS ?= -p $(VM_SSH_HOST) $(VM_SSH_HOST_KEY_OPTS) $(VM_SSH_IDENTITY_OPTS)
VM_BOOTSTRAP_SSH_OPTS ?= -p $(VM_SSH_HOST) $(VM_SSH_HOST_KEY_OPTS)
VM_DISK ?= $(VM_STATE_DIR)/$(VM_HOST).qcow2
VM_CONFIG_DIR ?= /home/$(VM_USER)/nixos-config
VM_REBUILD_ACTION ?= switch
VM_REBUILD_SUDO ?= --sudo --ask-sudo-password
VM_TAR_EXCLUDES := --exclude=.git --exclude=.jj --exclude=.var --exclude=result
AGENT_VM_HOST ?= agent-vm
AGENT_VM_USER ?= paul
AGENT_VM_SSH_HOST ?= 2223
AGENT_VM_SSH_TARGET ?= $(AGENT_VM_USER)@localhost
AGENT_VM_SSH_OPTS ?= -p $(AGENT_VM_SSH_HOST) $(VM_SSH_HOST_KEY_OPTS)
AGENT_VM_STATE_DIR ?= $(VM_STATE_DIR)/$(AGENT_VM_HOST)
AGENT_VM_STATE_DIR_ABS := $(abspath $(AGENT_VM_STATE_DIR))

.PHONY: vm-build vm-run vm-ssh vm-ssh-setup vm-ssh-key vm-ssh-bootstrap-key vm-ssh-reset-key vm-deploy vm-copy-config vm-guest-switch agent-vm-build agent-vm-run agent-vm-ssh agent-vm-reset-key

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
	mkdir -p $(VM_STATE_DIR)
	NIX_DISK_IMAGE="$(VM_DISK)" \
	QEMU_NET_OPTS="hostfwd=tcp::$(VM_SSH_HOST)-:22" \
	QEMU_KERNEL_PARAMS="console=ttyAMA0" \
	./result/bin/run-$(VM_HOST)-vm -nographic

vm-ssh-setup:
	mkdir -p $(VM_STATE_DIR) $(dir $(VM_SSH_KNOWN_HOSTS))

vm-ssh-key: vm-ssh-setup
	test -f "$(VM_SSH_KEY)" || ssh-keygen -t ed25519 -N "" -C "$(VM_USER)@$(VM_HOST)-local" -f "$(VM_SSH_KEY)"
	test -f "$(VM_SSH_KEY).pub" || ssh-keygen -y -f "$(VM_SSH_KEY)" > "$(VM_SSH_KEY).pub"
	chmod 600 "$(VM_SSH_KEY)"

vm-ssh-bootstrap-key: vm-ssh-key
	cat "$(VM_SSH_KEY).pub" | ssh $(VM_BOOTSTRAP_SSH_OPTS) $(VM_SSH_TARGET) 'set -eu; mkdir -p ~/.ssh; chmod 700 ~/.ssh; touch ~/.ssh/authorized_keys; chmod 600 ~/.ssh/authorized_keys; key_file=$$(mktemp); cat > "$$key_file"; grep -qxF -f "$$key_file" ~/.ssh/authorized_keys || cat "$$key_file" >> ~/.ssh/authorized_keys; rm "$$key_file"'

vm-ssh: vm-ssh-key
	ssh $(VM_SSH_OPTS) $(VM_SSH_TARGET)

vm-ssh-reset-key: vm-ssh-setup
	touch $(VM_SSH_KNOWN_HOSTS)
	ssh-keygen -R "[localhost]:$(VM_SSH_HOST)" -f "$(VM_SSH_KNOWN_HOSTS)"

vm-deploy: vm-ssh-key
	NIX_SSHOPTS="$(VM_SSH_OPTS)" \
	nix run --inputs-from . nixpkgs#nixos-rebuild -- $(VM_REBUILD_ACTION) \
		--flake ".#$(VM_HOST)" \
		--target-host "$(VM_SSH_TARGET)" \
		$(VM_REBUILD_SUDO)

vm-copy-config: vm-ssh-key
	ssh $(VM_SSH_OPTS) $(VM_SSH_TARGET) 'mkdir -p $(VM_CONFIG_DIR)'
	tar $(VM_TAR_EXCLUDES) -cf - . | ssh $(VM_SSH_OPTS) $(VM_SSH_TARGET) 'tar -C $(VM_CONFIG_DIR) -xf -'

vm-guest-switch: vm-copy-config
	ssh -t $(VM_SSH_OPTS) $(VM_SSH_TARGET) 'cd $(VM_CONFIG_DIR) && sudo nixos-rebuild $(VM_REBUILD_ACTION) --flake ".#$(VM_HOST)"'

agent-vm-build:
	nix build .#nixosConfigurations.$(AGENT_VM_HOST).config.microvm.declaredRunner

agent-vm-run: agent-vm-build
	mkdir -p $(AGENT_VM_STATE_DIR)
	cd $(AGENT_VM_STATE_DIR) && $(abspath result/bin/microvm-run)

agent-vm-ssh: vm-ssh-setup
	ssh $(AGENT_VM_SSH_OPTS) $(AGENT_VM_SSH_TARGET)

agent-vm-reset-key: vm-ssh-setup
	touch $(VM_SSH_KNOWN_HOSTS)
	ssh-keygen -R "[localhost]:$(AGENT_VM_SSH_HOST)" -f "$(VM_SSH_KNOWN_HOSTS)"

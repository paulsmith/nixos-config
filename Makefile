all:
	sudo darwin-rebuild switch --flake .#`hostname`

paulsmith-HJ6D3J627M:
	sudo darwin-rebuild switch --flake .#$@

venus:
	sudo darwin-rebuild switch --flake .#$@

oberon:
	sudo darwin-rebuild switch --flake .#$@

update:
	nix flake update

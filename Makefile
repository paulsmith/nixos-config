all:
	darwin-rebuild switch --flake .#`hostname`

paulsmith-HJ6D3J627M:
	darwin-rebuild switch --flake .#$@

venus:
	darwin-rebuild switch --flake .#$@

oberon:
	darwin-rebuild switch --flake .#$@

update-unstable:
	nix flake lock --update-input nixpkgs-unstable

all:
	@echo "Usage: make <name-of-host>"

paulsmith-HJ6D3J627M:
	darwin-rebuild switch --flake .#$@

venus:
	darwin-rebuild switch --flake .#$@

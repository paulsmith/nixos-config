{ pkgs, ... }:
{
  nix-rosetta-builder = {
    onDemand = true;
  };

  environment.systemPackages = [ pkgs.google-cloud-sdk ];
}

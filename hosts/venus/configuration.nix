{ username
, hostname
, nextdnsProfile
,
}:
{ config, pkgs, ... }:
let
  baseConfig = import ../../common/hosts/personal-host-base.nix {
    inherit username hostname nextdnsProfile;
  };
in
{
  imports = [ baseConfig ];


}

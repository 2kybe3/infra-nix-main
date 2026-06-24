{ lib, config, ... }:
let
  cfg = config.kylib;
in
{
  options.kylib = {
    caddy = lib.mkOption {
      type = lib.types.attrs;
      default = import ./caddy.nix;
    };
    baseDomain = lib.mkOption {
      type = lib.types.str;
      default = "kybe.xyz";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      default = "${config.networking.hostName}.${cfg.baseDomain}";
    };
  };
}

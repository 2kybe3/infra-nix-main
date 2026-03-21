{config}: rec {
  caddy = import ./caddy.nix {inherit config;};
  hostName = "${config.networking.hostName}";
  baseDomain = "kybe.xyz";
  domain = "${config.kybe.lib.hostName}.${baseDomain}";
}

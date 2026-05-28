{ config, ... }:
let
  inherit (config.kylib.caddy)
    createCaddyProxy
    ;

  domain = "loki.${config.kylib.domain}";
in
{
  services.loki = {
    enable = true;

    configFile = ./loki.yaml;
  };

  services.caddy.virtualHosts.${domain} = createCaddyProxy 3100;
}

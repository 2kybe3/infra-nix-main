{config, ...}: let
  inherit
    (config.kybe.lib.caddy)
    createCaddyProxy
    ;

  domain = "loki.${config.kybe.lib.domain}";
in {
  services.loki = {
    enable = true;

    configFile = ./loki.yaml;
  };

  services.caddy.virtualHosts.${domain} = createCaddyProxy 3100;
}

{
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (config.kylib)
    domain
    ;
  inherit (config.kylib.caddy)
    createRawCaddyProxy
    ;

  vhosts = config.services.caddy.virtualHosts;
  names = builtins.attrNames vhosts;
  links = builtins.concatStringsSep "\n" (map (name: "https://${name}") names);
in
{
  sops.secrets.caddy = {
    sopsFile = "${self}/secrets/caddy.env.bin";
    format = "binary";
  };

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.3" ];
      hash = "sha256-M1vg27XU0y54DBffviY5fMkLorF7sKsrZP3Yiwq8sZ0=";
    };

    virtualHosts."${domain}" = createRawCaddyProxy "respond \"${config.kylib.hostName}\n\n${links}\"";
    environmentFile = config.sops.secrets.caddy.path;
  };

  networking.firewall = {
    allowedUDPPorts = [
      443
    ];
    allowedTCPPorts = [
      80
      443
    ];
  };
}

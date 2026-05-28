{
  self,
  config,
  ...
}:
let
  inherit (config.kylib)
    domain
    ;
  inherit (config.kylib.caddy)
    createCaddyProxy
    ;
in
{
  sops.secrets.miniflux = {
    sopsFile = "${self}/secrets/miniflux.env.bin";
    format = "binary";
  };

  services.miniflux = {
    enable = true;
    createDatabaseLocally = true;
    adminCredentialsFile = config.sops.secrets.miniflux.path;
    config.LISTEN_ADDR = "localhost:4444";
  };

  services.caddy.virtualHosts."rss.${domain}" = createCaddyProxy 4444;
}

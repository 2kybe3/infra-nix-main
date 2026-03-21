{
  self,
  config,
  ...
}: let
  inherit
    (config.kybe.lib.caddy)
    createCaddyProxy
    ;

  domain = "grafana.${config.kybe.lib.domain}";
in {
  sops.secrets = {
    grafana-key = {
      sopsFile = "${self}/secrets/monitoring.yaml";
      owner = "grafana";
      key = "key";
    };
    grafana-pass = {
      sopsFile = "${self}/secrets/monitoring.yaml";
      owner = "grafana";
      key = "pass";
    };
    mail-system = {
      sopsFile = "${self}/secrets/mail-system.yaml";
      owner = "grafana";
    };
  };

  services.grafana = {
    enable = true;

    settings = {
      server = {
        domain = domain;
        http_port = 2342;
        http_addr = "127.0.0.1";
      };
      security = {
        admin_user = "kybe";
        admin_password = "$__file{${config.sops.secrets.grafana-pass.path}}";
        admin_email = "kybe+grafana@kybe.xyz";
        secret_key = "$__file{${config.sops.secrets.grafana-key.path}}";
        cookie_secure = true;
      };
      smtp = {
        enabled = true;
        host = "mail.kybe.xyz:587";
        user = "system@kybe.xyz";
        from_address = "system+grafana@kybe.xyz";
        password = "$__file{${config.sops.secrets.mail-system.path}}";
      };
    };
  };

  services.caddy.virtualHosts.${domain} = createCaddyProxy 2342;
}

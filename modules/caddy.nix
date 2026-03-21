{
  self,
  config,
  ...
}: let
  inherit
    (config.kybe.lib)
    domain
    ;
  inherit
    (config.kybe.lib.caddy)
    createRawCaddyProxy
    ;

  vhosts = config.services.caddy.virtualHosts;
  names = builtins.attrNames vhosts;
  links = builtins.concatStringsSep "\n" (map (name: "https://${name}") names);
in {
  sops.secrets.acme = {
    sopsFile = "${self}/secrets/acme.env.bin";
    format = "binary";
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "kybe@kybe.xyz";
      credentialsFile = config.sops.secrets.acme.path;
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      dnsPropagationCheck = true;
      postRun = ''
        chmod g+rwx .
        chmod g+rwx key.pem cert.pem
      '';
    };

    certs."${domain}" = {
      domain = "${domain}";
      extraDomainNames = ["*.${domain}"];
    };
  };

  services.caddy = {
    enable = true;

    virtualHosts."${domain}" = createRawCaddyProxy "respond \"${config.kybe.lib.hostName}\n\n${links}\"";
  };

  users.groups.acme.members = [
    "caddy"
  ];
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}

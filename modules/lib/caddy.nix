{config}: let
  inherit
    (config.kybe.lib)
    domain
    ;
  # TODO: use cloudflare cert plugin
  certloc = "/var/lib/acme/${domain}";
in {
  createCaddyProxy = port: {
    extraConfig = ''
      encode
      tls ${certloc}/cert.pem ${certloc}/key.pem
      reverse_proxy localhost:${toString port}
    '';
  };
  createRawCaddyProxy = block: {
    extraConfig = ''
      encode
      tls ${certloc}/cert.pem ${certloc}/key.pem

      ${block}
    '';
  };
}

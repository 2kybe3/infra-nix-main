{
  createCaddyProxy = port: {
    extraConfig = ''
      encode
      tls {
        dns cloudflare {env.CF_API_TOKEN}
        resolvers 1.1.1.1
      }

      reverse_proxy localhost:${toString port}
    '';
  };
  createRawCaddyProxy = block: {
    extraConfig = ''
      encode
      tls {
        dns cloudflare {env.CF_API_TOKEN}
        resolvers 1.1.1.1
      }

      ${block}
    '';
  };
}

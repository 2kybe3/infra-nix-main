{config, ...}: {
  networking = {
    nftables.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [22];
    };
    hosts."127.0.0.1" = [
      "*.${config.kybe.lib.domain}"
      "${config.kybe.lib.domain}"
    ];
    nameservers = ["10.0.4.1"];
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      Domains = ["~."];
      DNSOverTLS = "false";
      DNSSEC = "false";
    };
  };
}

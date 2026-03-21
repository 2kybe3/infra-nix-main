{
  lib,
  self,
  pkgs,
  config,
  ...
}: let
  inherit
    (config.kybe.lib)
    domain
    ;
  inherit
    (config.kybe.lib.caddy)
    createCaddyProxy
    ;

  address = "transmission.${domain}";

  wgNamespace = "mullvad";
  wgInterface = "mullvad0";
  wgDns = "10.64.0.1";
  wgIps = [
    "10.66.190.176/32"
    "fc00:bbbb:bbbb:bb01::3:beaf/128"
  ];
  wgEndpoint = "193.32.248.66:51820";
  wgPublicKey = "0qSP0VxoIhEhRK+fAHVvmfRdjPs2DmmpOCNLFP/7cGw=";
in {
  services = {
    transmission = {
      enable = true;
      openPeerPorts = true;
      package = pkgs.transmission_4;
      group = "media";

      settings = {
        rpc-bind-address = "127.0.0.1";
        rpc-url = "/transmission/";
        rpc-host-whitelist-enabled = true;
        rpc-host-whitelist = address;

        rpc-port = 9091;
        peer-port = 39894;

        script-torrent-done-enabled = true;
      };
    };

    caddy.virtualHosts."${address}" = createCaddyProxy 9091;
  };

  systemd.services = {
    transmission = {
      requires = ["netns-${wgNamespace}.service"];
      after = [
        "netns-${wgNamespace}.service"
        "wireguard-${wgInterface}.service"
      ];
      serviceConfig = {
        NetworkNamespacePath = "/var/run/netns/${wgNamespace}";
        AmbientCapabilities = lib.mkForce "CAP_NET_RAW";
        NoNewPrivileges = lib.mkForce false;
      };
    };

    transmission-namespace-forward = {
      wantedBy = ["multi-user.target"];
      partOf = ["transmission.service"];
      requires = ["netns-${wgNamespace}.service"];
      after = [
        "netns-${wgNamespace}.service"
        "transmission.service"
      ];
      serviceConfig = {
        Restart = "on-failure";
        ExecStart = let
          socatBin = "${pkgs.socat}/bin/socat";
          transmissionAddress = config.services.transmission.settings.rpc-bind-address;
          transmissionRPCPort = toString config.services.transmission.settings.rpc-port;
        in ''
          ${socatBin} tcp-listen:${transmissionRPCPort},fork,reuseaddr \
          exec:'${pkgs.iproute2}/bin/ip netns exec ${wgNamespace} ${socatBin} STDIO "tcp-connect:${transmissionAddress}:${transmissionRPCPort}"',nofork
        '';
      };
    };

    "netns-${wgNamespace}" = {
      description = "Network namespace ${wgNamespace}";
      before = ["wireguard-${wgInterface}.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.iproute2}/bin/ip netns add ${wgNamespace}";
        ExecStop = "${pkgs.iproute2}/bin/ip netns del ${wgNamespace}";
      };
    };
  };

  sops.secrets."mullvad-key" = {
    sopsFile = "${self}/secrets/mullvad.yaml";
  };

  networking.wireguard = {
    useNetworkd = false;
    interfaces.${wgInterface} = {
      ips = wgIps;
      privateKeyFile = config.sops.secrets."mullvad-key".path;
      interfaceNamespace = wgNamespace;
      mtu = 1320;
      peers = [
        {
          endpoint = wgEndpoint;
          publicKey = wgPublicKey;
          allowedIPs = [
            "0.0.0.0/0"
            "::0/0"
          ];
          persistentKeepalive = 15;
        }
      ];

      postSetup = [
        "${pkgs.iproute2}/bin/ip -n ${wgNamespace} link set lo up"
        "${pkgs.iproute2}/bin/ip -n ${wgNamespace} route add default dev ${wgInterface} || true"
      ];
    };
  };

  environment.etc."netns/${wgNamespace}/resolv.conf".text = ''
    nameserver ${wgDns}
    options edns0 trust-ad ndots:0
  '';
}

{
  self,
  lib,
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

  syncthingUser = "root";
  homeDir = "/root";
  folderDir = "${homeDir}/syncthing";
  dataDir = folderDir;

  knxDevice = "knx";
  serverDevice = "server";
  phoneDevice = "phone";

  allDevices = [
    knxDevice
    serverDevice
    phoneDevice
  ];

  base = {
    devices = allDevices;
  };

  # Generate a folder ID (similar to Syncthing's default format):
  #   nix run ./tools/syncthing-folder-id-gen
  folderDefs = {
    "phone/documents" = {
      id = "nbrf9-2w4wy";
      path = "phone/Documents";
    };
    "pictures" = {
      id = "labpe-fxw3q";
      path = "phone/pictures";
    };
    "phone/dcim" = {
      id = "d7tbq-371tj";
      path = "phone/dcim";
    };
    "phone/aesis" = {
      id = "c2vbp-mdgxw";
      path = "phone/aesis";
    };
    "obsidian" = {
      id = "erg2o-nnpy1";
      path = "obsidian";
    };
    "documents" = {
      id = "gqe7d-gqjr2";
      path = "documents";
    };

    "keepass" = {
      id = "zepjc-kbxe4";
      path = "keepass";
      versioning = {
        type = "staggered";
        params.maxAge = toString (60 * 60 * 24 * 7); # 7 days
      };
    };
  };
in {
  sops.secrets = {
    syncthingPass = {
      sopsFile = "${self}/secrets/syncthing.yaml";
      owner = config.services.syncthing.user;
    };
    syncthingKey = {
      sopsFile = "${self}/secrets/${config.kybe.lib.hostName}-syncthing-key.pem";
      format = "binary";
    };
    syncthingCert = {
      sopsFile = "${self}/secrets/${config.kybe.lib.hostName}-syncthing-cert.pem";
      format = "binary";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      22000
    ];
    allowedUDPPorts = [
      22000
      21027
    ];
  };

  systemd.tmpfiles.rules = lib.mkIf (config.kybe.lib.hostName == "knx") [
    "L+ ${homeDir}/Documents - - - - /home/kybe/syncthing/documents"
  ];

  services.caddy.virtualHosts."syncthing.${domain}" = createCaddyProxy 8384;

  services.syncthing = {
    enable = true;
    overrideDevices = true;
    overrideFolders = true;
    inherit dataDir;
    user = syncthingUser;
    guiAddress = "0.0.0.0:8384";
    guiPasswordFile = config.sops.secrets.syncthingPass.path;
    cert = config.sops.secrets.syncthingCert.path;
    key = config.sops.secrets.syncthingKey.path;

    settings = {
      gui = {
        user = "kybe";
        insecureAdminAccess = false;
        insecureSkipHostcheck = true;
        metricsWithoutAuth = true;
        theme = "black";
      };
      options = {
        urAccepted = -1;
        localAccounceEnabled = false;
        relaysEnabled = true;
      };
      devices = {
        ${serverDevice} = {
          id = "X2TZ44D-O26DTNM-WRPIFJP-M75HMBQ-3WH4KLQ-COS7E3P-FE2MJAR-WU2N6AH";
          introducer = true;
        };
        ${knxDevice} = {
          id = "PPZGUI7-QHAZ6O7-CGCOVXB-BWZ5LEN-Y5CEGES-TMJDILA-SKQLDPK-I4CDUAN";
        };
        ${phoneDevice} = {
          id = "P366B4T-SOUZTBV-G4G5IE2-7MXQ4DQ-DFKXKKM-WVBJMSZ-Q7ZPOAN-32MUFAY";
        };
      };

      folders =
        lib.mapAttrs
        (_: v:
          base
          // {
            id = v.id;
            path = "${folderDir}/${v.path}";
          }
          // lib.optionalAttrs (v ? versioning) {
            versioning = v.versioning;
          })
        folderDefs;
    };
  };
}

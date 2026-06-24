{
  self,
  ...
}:
let
  modules = [
    "arr"
    "ssh"
    "nix"
    "sops"
    "caddy"
    "kylib"
    "packages"
    "miniflux"
    "torrents"
    "journald"
    "syncthing"
    "monitoring"
    "networking"
    "webhook-router"
  ];

  moduleImports = map (
    m:
    let
      path = "${self}/modules/${m}";
    in
    if builtins.pathExists (path + ".nix") then path + ".nix" else path
  ) modules;
in
{
  imports = [
    ./proxmox.nix
  ]
  ++ moduleImports;

  networking = {
    hostName = "nix-main";
    hostId = "e2775ce5";
  };

  system.stateVersion = "25.05";
}

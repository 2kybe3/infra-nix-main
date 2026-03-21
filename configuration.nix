{
  self,
  pkgs,
  ...
}: {
  imports = [
    ./proxmox.nix

    "${self}/modules/lib"
    "${self}/modules/caddy"
    "${self}/modules/arr.nix"
    "${self}/modules/nix.nix"
    "${self}/modules/sops.nix"
    "${self}/modules/monitoring"
    "${self}/modules/networking"
    "${self}/modules/torrents.nix"
    "${self}/modules/journald.nix"
    "${self}/modules/syncthing.nix"
  ];

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  kybe.lib.hostName = "nix-main";
  networking.hostId = "e2775ce5";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM7irWuDZwx7ZvPSiUwBbxUxKL/7aMQmy/8oxput1bID kybe@knx"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOQl0E3yt31laA6LoeQcXoUCbmjDBi/qH6E/IlC/lMtF nix-builder -> nix-main"
  ];

  system.stateVersion = "25.05";
}

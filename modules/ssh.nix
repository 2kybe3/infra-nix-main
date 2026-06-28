{
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM7irWuDZwx7ZvPSiUwBbxUxKL/7aMQmy/8oxput1bID kybe@knx"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/cSa7NMgCbuAOI7Nw1nP5RaysLGBpEthFtfPvL+2vR infra deployer"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOQl0E3yt31laA6LoeQcXoUCbmjDBi/qH6E/IlC/lMtF nix-builder -> nix-main"
  ];
}

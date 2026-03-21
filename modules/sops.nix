{
  self,
  pkgs,
  ...
}: let
in {
  environment.systemPackages = with pkgs; [
    age
    sops
  ];
  sops = {
    defaultSopsFile = "${self}/secrets/secrets.yaml";
    defaultSopsFormat = "yaml";

    age.keyFile = "/nix/persist/var/lib/sops-nix/key.txt";
  };
}

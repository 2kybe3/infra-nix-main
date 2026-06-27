{
  nix = {
    enable = true;
    channel.enable = false;
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "pipe-operators"
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
      use-xdg-base-directories = true;
    };
  };
}

{
  projectRootFile = "flake.nix";
  programs = {
    typos.enable = true;
    nixfmt.enable = true;
  };
  settings.excludes = [
    ".sops.yaml"
    "secrets/*"
    "result/*"
    ".git/*"
  ];
}

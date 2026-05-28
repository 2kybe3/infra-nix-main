{
  projectRootFile = "flake.nix";
  programs = {
    typos.enable = true;
    nixfmt.enable = true;
    yamlfmt.enable = true;
  };
  settings.formatter.typos.excludes = [
    ".sops.yaml"
    "secrets/*"
  ];
  settings.excludes = [
    "result/*"
    ".git/*"
  ];
}

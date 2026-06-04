{
  description = "nix-main";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    webhook-router = {
      url = "https://git.kybe.xyz/2kybe3/webhook-router/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt,
      sops-nix,
      flake-utils,
      webhook-router,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations."nix-main" = nixpkgs.lib.nixosSystem {
        inherit system pkgs;

        specialArgs = {
          inherit self;
        };

        modules = [
          ./host/infra-nix-main/default.nix
          sops-nix.nixosModules.sops
          webhook-router.nixosModules.webhook-router
        ];
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        treefmt-eval = treefmt.lib.evalModule pkgs ./treefmt.nix;
      in
      {
        checks.formatting = treefmt-eval.config.build.check self;
        formatter = treefmt-eval.config.build.wrapper;
      }
    );
}

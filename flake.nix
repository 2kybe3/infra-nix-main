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
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt,
      sops-nix,
      flake-utils,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {
      nixosConfigurations."nix-main" = nixpkgs.lib.nixosSystem {
        inherit system pkgs;

        specialArgs = {
          inherit self;
        };

        modules = [
          ./configuration.nix
          sops-nix.nixosModules.sops
        ];
      };
      formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
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

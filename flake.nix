{
  description = "VSCodium with extensions";

  nixConfig = {
    extra-substituters = [ "https://helix.cachix.org" ];
    extra-trusted-public-keys = [ "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs=" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-vscode-ext.url = "github:nix-community/nix-vscode-extensions";
    nixvim.url = "github:nix-community/nixvim";
    wrappers.url = "github:lassulus/wrappers";
    helix.url = "github:helix-editor/helix";

    nix-vscode-ext.inputs.nixpkgs.follows = "nixpkgs";
    # https://github.com/nix-community/nixvim/issues/4023#issuecomment-3607875748
    # nixvim.inputs.nixpkgs.follows = "nixpkgs";
    wrappers.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      nix-vscode-ext,
      nixvim,
      wrappers,
      helix,
      ...
    }:
    let
      inherit (nixpkgs.lib) composeManyExtensions;

      overlays.default =
        let
          helix-overlay = final: prev: {
            helix = helix.packages.${prev.stdenv.hostPlatform.system}.default;
          };

          my-overlay = final: prev: {
            my-codium = final.callPackage ./code.nix { pkgName = "vscodium"; };
            my-vscode = final.callPackage ./code.nix { pkgName = "vscode"; };
            my-cursor = final.callPackage ./code.nix { pkgName = "code-cursor"; };
            my-antigravity = final.callPackage ./code.nix { pkgName = "antigravity-ide"; };
            my-helix = import ./helix {
              inherit wrappers;
              pkgs = final;
            };
            my-nvim =
              let
                conf = nixvim.lib.evalNixvim {
                  inherit (final.stdenv) system;
                  modules = [ ./nvim.nix ];
                };
              in
              conf.config.build.package;
          };
        in
        composeManyExtensions [
          helix-overlay
          nix-vscode-ext.overlays.default
          my-overlay
        ];

      eachSystem =
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ overlays.default ];
            config.allowUnfree = true;
          };

          packages = rec {
            inherit (pkgs)
              my-codium
              my-vscode
              my-cursor
              my-antigravity
              my-nvim
              my-helix
              ;
            default = my-helix;
          };

          devShells.default = pkgs.mkShell {
            name = "codium";
            buildInputs = [ packages.default ];
            shellHook = ''
              printf "Codium with extensions:\n"
              codium --list-extensions
            '';
          };
        in
        {
          inherit packages devShells;
        };
    in
    {
      inherit overlays;
      inherit (flake-utils.lib.eachDefaultSystem eachSystem) devShells packages;
    };
}

{
  description = "My preferred editors";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-vscode-ext.url = "github:nix-community/nix-vscode-extensions";
    nvf.url = "github:notashelf/nvf";
    wrappers.url = "github:lassulus/wrappers";

    nix-vscode-ext.inputs.nixpkgs.follows = "nixpkgs";
    nvf.inputs.nixpkgs.follows = "nixpkgs";
    wrappers.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      nix-vscode-ext,
      wrappers,
      nvf,
      ...
    }:
    let
      inherit (nixpkgs.lib) composeManyExtensions;

      overlays.default =
        let
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
                conf = nvf.lib.neovimConfiguration {
                  inherit (final) pkgs;
                  modules = [ ./nvim.nix ];
                };
              in
              conf.neovim;
          };
        in
        composeManyExtensions [
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

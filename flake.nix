{
  description = "VSCodium with extensions";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-vscode-ext.url = "github:nix-community/nix-vscode-extensions";
    nixvim.url = "github:nix-community/nixvim";

    nix-vscode-ext.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      nix-vscode-ext,
      nixvim,
      ...
    }:
    let
      inherit (nixpkgs.lib) composeManyExtensions;

      overlays.default =
        let
          my-pkgs =
            final: prev:
            let
              pkgs = final;
            in
            {
              my-codium = pkgs.callPackage ./code.nix { pkgName = "vscodium"; };
              my-vscode = pkgs.callPackage ./code.nix { pkgName = "vscode"; };
              my-cursor = pkgs.callPackage ./code.nix { pkgName = "code-cursor"; };
              my-antigravity = pkgs.callPackage ./code.nix { pkgName = "antigravity"; };
              my-nvim = nixvim.legacyPackages."${final.stdenv.system}".makeNixvim ./nvim.nix;
              my-helix-config = pkgs.callPackage ./helix-config.nix { };
            };
        in
        composeManyExtensions [
          nix-vscode-ext.overlays.default
          my-pkgs
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
              my-helix-config
              ;
            default = my-codium;
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

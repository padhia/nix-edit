{
  description = "VSCodium with extensions";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    vscode-ext.url = "github:nix-community/nix-vscode-extensions";
    nixvim.url = "github:nix-community/nixvim";

    vscode-ext.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      vscode-ext,
      nixvim,
      ...
    }:
    let
      overlays.default =
        final: prev:
        let
          pkgs = final;
          exts = vscode-ext.extensions.${final.stdenv.system};
        in
        {
          my-code = import ./code.nix {
            inherit pkgs exts;
            pkgName = "vscodium";
          };
          my-cursor = import ./code.nix {
            inherit pkgs exts;
            pkgName = "code-cursor";
          };
          my-antigravity = import ./code.nix {
            inherit pkgs exts;
            pkgName = "antigravity";
          };
          my-nvim = nixvim.legacyPackages."${final.stdenv.system}".makeNixvim ./nvim.nix;
        };

      eachSystem =
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ overlays.default ];
            config.allowUnfree = true;
          };

          inherit (pkgs.lib) getExe;

          packages = {
            inherit (pkgs)
              my-code
              my-cursor
              my-antigravity
              my-nvim
              ;
          };

          apps = rec {
            code = {
              type = "app";
              program = getExe packages.my-code;
            };
            cursor = {
              type = "app";
              program = getExe packages.my-cursor;
            };
            antigravity = {
              type = "app";
              program = getExe packages.my-antigravity;
            };
            nvim = {
              type = "app";
              program = getExe packages.my-nvim;
            };
            default = code;
          };

          devShells.default = pkgs.mkShell {
            name = "vscode";
            buildInputs = [ packages.default ];
            shellHook = ''
              printf "VSCodium with extensions:\n"
              codium --list-extensions
            '';
          };
        in
        {
          inherit packages apps devShells;
        };
    in
    {
      inherit overlays;
      inherit (flake-utils.lib.eachDefaultSystem eachSystem) devShells packages apps;
    };
}

{
  description = "VSCodium with extensions";

  inputs = {
    nixpkgs.url     = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    vscode-ext.url  = "github:nix-community/nix-vscode-extensions";
    nixvim.url      = "github:nix-community/nixvim";

    vscode-ext.inputs.nixpkgs.follows     = "nixpkgs";
    vscode-ext.inputs.flake-utils.follows = "flake-utils";
    nixvim.inputs.nixpkgs.follows         = "nixpkgs";
  };

  outputs = {nixpkgs, flake-utils, vscode-ext, nixvim, ...}:
  let
    overlays.default = final: prev: {
      my-code = import ./code.nix {
        pkgs = final;
        exts = vscode-ext.extensions.${final.stdenv.system};
      };
      my-nvim = nixvim.legacyPackages."${final.stdenv.system}".makeNixvim ./nvim.nix;
    };

    eachSystem = system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlays.default ];
        config.allowUnfree = true;
      };

      packages = {
        inherit (pkgs) my-code my-nvim;
      };

      apps = rec {
        code = {
          type = "app";
          program = "${packages.my-code}/bin/codium";
        };
        nvim = {
          type = "app";
          program = "${packages.my-nvim}/bin/nvim";
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
    in {
      inherit packages apps devShells;
    };
  in {
    inherit overlays;
    inherit (flake-utils.lib.eachDefaultSystem eachSystem) devShells packages apps;
  };
}

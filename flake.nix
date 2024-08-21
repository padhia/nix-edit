{
  description = "VSCodium with extensions";

  inputs = {
    nixpkgs.url     = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    vscode-ext.url  = "github:nix-community/nix-vscode-extensions";

    vscode-ext.inputs.flake-utils.follows = "flake-utils";
    vscode-ext.inputs.nixpkgs.follows     = "nixpkgs";
  };

  outputs = {nixpkgs, flake-utils, vscode-ext, ...}:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        mkt = vscode-ext.extensions.${system}.vscode-marketplace;
        vsx = vscode-ext.extensions.${system}.open-vsx;

        base-ext = with mkt; [
          bierner.markdown-mermaid
          coenraads.disableligatures
          darkriszty.markdown-table-prettify
          editorconfig.editorconfig
          humao.rest-client
          jdinhlife.gruvbox
          mhutchie.git-graph
          pkief.material-icon-theme
          teabyii.ayu
          streetsidesoftware.code-spell-checker
        ];

        scala-ext = with vsx; [
          mkt.baccata.scaladex-search
          scala-lang.scala
          scalameta.metals
          mkt.disneystreaming.smithy
        ];

        python-ext = with mkt; [
          charliermarsh.ruff
          ms-python.debugpy
          ms-python.python
          ms-python.vscode-pylance
          ms-toolsai.jupyter
          ms-toolsai.jupyter-keymap
          ms-toolsai.jupyter-renderers
          ms-toolsai.vscode-jupyter-cell-tags
          ms-toolsai.vscode-jupyter-slideshow
        ];

        misc-ext = with mkt; [
          luggage66.awk
          vsx.dhall.dhall-lang
          vsx.dhall.vscode-dhall-lsp-server
          sclu1034.justfile
          vsx.tamasfe.even-better-toml
          tweag.vscode-nickel
          vsx.snowflake.snowflake-vsc
          vsx.redhat.vscode-yaml
        ];

        remote-ext = with mkt; [
          ms-vscode-remote.remote-containers
          ms-vscode-remote.remote-ssh
          ms-vscode-remote.remote-ssh-edit
          ms-vscode-remote.remote-wsl
          ms-vscode-remote.vscode-remote-extensionpack
          ms-vscode.remote-explorer
          ms-vscode.remote-server
        ];

        packages.default = pkgs.vscode-with-extensions.override {
          vscode = pkgs.vscodium;
          vscodeExtensions = base-ext ++ scala-ext ++ python-ext ++ misc-ext ++ remote-ext;
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
        inherit packages devShells;
      }
    );
}

{ pkgs, ... }:
let
  inherit (pkgs) lib;
  toml = pkgs.formats.toml { };

  languages =
    let
      python = {
        name = "python";
        file-types = [
          "py"
          "pyi"
        ];
        roots = [ "pyproject.toml" ];
        formatter = {
          command = lib.getExe pkgs.ruff;
          args = [
            "format"
            "-"
          ];
        };
        language-servers = [
          "pyrefly"
          "ruff"
        ];
      };

      nix = {
        name = "nix";
        file-types = [ "nix" ];
        indent = {
          tab-width = 2;
          unit = " ";
        };
        formatter = {
          command = lib.getExe pkgs.nixfmt;
        };
      };

      sql = {
        name = "sql";
        file-types = [
          "sql"
          "ddl"
          "sp"
        ];
        indent = {
          tab-width = 4;
          unit = " ";
        };
      };

    in
    {
      language-servers = {
        pyrefly = {
          command = lib.getExe pkgs.pyrefly;
          args = [ "lsp" ];
          except-features = [ "format" ];
        };
        ruff = {
          command = lib.getExe pkgs.ruff;
          args = [ "server" ];
          only-features = [ "format" ];
        };
      };
      language = [
        python
        nix
        sql
      ];
    };

  settings = {
    theme = "gruvbox_dark_hard";
    editor = {
      true-color = true;
      cursor-shape.insert = "bar";
      statusline = {
        right = [
          "workspace-diagnostics"
          "version-control"
          "position"
        ];
      };
      indent-guides.render = true;
      trim-final-newlines = true;
      trim-trailing-whitespace = true;
    };
  };
in
pkgs.runCommand "my-helix-config" { } ''
  mkdir -p $out

  ln -s ${toml.generate "config.toml" settings} $out/config.toml
  ln -s ${toml.generate "languages.toml" languages} $out/languages.toml
''

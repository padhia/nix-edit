{ pkgs }:
let
  inherit (pkgs.lib) getExe;
  python = {
    name = "python";
    file-types = [
      "py"
      "pyi"
    ];
    roots = [ "pyproject.toml" ];
    formatter = {
      command = getExe pkgs.ruff;
      args = [
        "format"
        "-"
      ];
    };
    language-servers = [
      {
        name = "pyrefly";
        except-features = [ "format" ];
      }
      {
        name = "ruff";
        only-features = [ "format" ];
      }
    ];
  };

  nix = {
    name = "nix";
    file-types = [ "nix" ];
    indent = {
      tab-width = 2;
      unit = "  ";
    };
    formatter = {
      command = getExe pkgs.nixfmt;
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
      unit = "    ";
    };
  };

  scala = {
    name = "scala";
    file-types = [
      "scala"
      "mill"
      "sc"
      "sbt"
    ];
    roots = [
      "build.sbt"
      "build.mill"
    ];
    formatter = {
      command = getExe pkgs.scalafmt;
      args = [ "--stdout" ];
    };
    language-servers = [ "metals" ];
  };

  pkl = {
    name = "pkl";
    file-types = [ "pkl" ];
    comment-token = "//";
    scope = "source.pkl";
    language-servers = [ "pkl-lsp" ];
    indent = {
      tab-width = 2;
      unit = "  ";
    };
    formatter.command = "pkl-formatter";
    auto-format = true;
  };

  kcl = {
    name = "kcl";
    scope = "source.kcl";
    file-types = [ "k" ];
    roots = [
      "kcl.mod"
      "kcl.yaml"
    ];
    comment-tokens = "#";
    indent = {
      tab-width = 4;
      unit = "    ";
    };
    language-servers = [ "kcl-lsp" ];
    formatter = {
      command = "kcl-formatter";
      args = [ ];
    };
    auto-format = true;
  };
in
[
  python
  nix
  sql
  scala
  pkl
  kcl
]

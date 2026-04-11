{
  pkgs,
  lib,
  pkgName ? "vscodium",
}:

let
  mkt = pkgs.nix-vscode-extensions.vscode-marketplace;
  vsx = pkgs.nix-vscode-extensions.open-vsx;

  base-ext = with vsx; [
    bierner.markdown-mermaid
    mkt.coenraads.disableligatures
    darkriszty.markdown-table-prettify
    davidanson.vscode-markdownlint
    editorconfig.editorconfig
    jdinhlife.gruvbox
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

  python-ext = [
    vsx.charliermarsh.ruff
    vsx.meta.pyrefly
    mkt.ms-python.debugpy
    mkt.ms-python.python
  ];

  jupyter-ext = with mkt.ms-toolsai; [
    jupyter
    jupyter-keymap
    jupyter-renderers
    vscode-jupyter-cell-tags
    vscode-jupyter-slideshow
  ];

  misc-ext = with vsx; [
    mkt.luggage66.awk
    mkt.sclu1034.justfile
    mkt.tweag.vscode-nickel
    tamasfe.even-better-toml
    snowflake.snowflake-vsc
    redhat.vscode-yaml
    bbenoist.nix
    jnoortheen.nix-ide
    humao.rest-client
  ];

  remote-ext = with mkt; [
    ms-vscode-remote.remote-ssh
    ms-vscode-remote.remote-containers
    ms-vscode.remote-explorer
    ms-vscode.remote-server
  ];

  isCode = builtins.elem pkgName [
    "vscode"
    "vscode-insiders"
    "codium"
  ];
in
pkgs.vscode-with-extensions.override {
  vscode = pkgs.${pkgName};
  vscodeExtensions =
    base-ext ++ scala-ext ++ python-ext ++ jupyter-ext ++ misc-ext ++ lib.optionals isCode remote-ext;
}

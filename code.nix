{
  pkgs,
  exts,
  pkgName ? "vscodium",
}:

let
  mkt = exts.vscode-marketplace;
  vsx = exts.open-vsx;

  base-ext = with mkt; [
    bierner.markdown-mermaid
    coenraads.disableligatures
    darkriszty.markdown-table-prettify
    editorconfig.editorconfig
    humao.rest-client
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

  python-ext = with mkt; [
    charliermarsh.ruff
    vsx.meta.pyrefly
    ms-python.debugpy
    ms-python.python
    ms-toolsai.jupyter
    ms-toolsai.jupyter-keymap
    ms-toolsai.jupyter-renderers
    ms-toolsai.vscode-jupyter-cell-tags
    ms-toolsai.vscode-jupyter-slideshow
  ];

  misc-ext = with mkt; [
    luggage66.awk
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
in
pkgs.vscode-with-extensions.override {
  vscode = pkgs.${pkgName};
  vscodeExtensions = base-ext ++ scala-ext ++ python-ext ++ misc-ext ++ remote-ext;
}

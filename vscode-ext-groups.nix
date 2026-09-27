{
  pkgs,
  install-remote ? false,
}:

let
  inherit (pkgs) lib;
  mkt = pkgs.nix-vscode-extensions.vscode-marketplace;
  vsx = pkgs.nix-vscode-extensions.open-vsx;

  base-ext = with vsx; [
    mkt.coenraads.disableligatures
    editorconfig.editorconfig
    jdinhlife.gruvbox
    pkief.material-icon-theme
    teabyii.ayu
  ];

  markdown-ext = with vsx; [
    davidanson.vscode-markdownlint
    yzhang.markdown-all-in-one
    takumii.markdowntable
    bierner.markdown-mermaid
  ];

  scala-ext = with vsx; [
    mkt.baccata.scaladex-search
    scala-lang.scala
    scalameta.metals
    disneystreaming.smithy
  ];

  remote = with mkt; [
    ms-vscode-remote.remote-ssh
    ms-vscode-remote.remote-containers
    ms-vscode.remote-explorer
    ms-vscode.remote-server
  ];

  python-ext =
    with vsx;
    [
      charliermarsh.ruff
      meta.pyrefly
      ms-python.debugpy
      ms-python.python
    ]
    ++ lib.optional install-remote remote;

  jupyter-ext = with vsx.ms-toolsai; [
    jupyter
    jupyter-keymap
    jupyter-renderers
    vscode-jupyter-cell-tags
    vscode-jupyter-slideshow
  ];

  misc-ext = with vsx; [
    mkt.luggage66.awk
    nefrob.vscode-just-syntax
    nickel-lang.vscode-nickel
    tamasfe.even-better-toml
    redhat.vscode-yaml
    bbenoist.nix
    jnoortheen.nix-ide
    humao.rest-client
    streetsidesoftware.code-spell-checker
  ];

  default = base-ext ++ markdown-ext ++ misc-ext;
  snowflake-ext = [ vsx.snowflake.snowflake-vsc ] ++ python-ext ++ jupyter-ext;
in
{
  inherit default remote;
  scala = default ++ scala-ext;
  python = default ++ python-ext;
  snowflake = default ++ snowflake-ext;
  all = default ++ scala-ext ++ snowflake-ext;
}

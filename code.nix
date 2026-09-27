{
  pkgs,
  pkgName ? "vscodium",
}:

let
  install-remote = builtins.elem pkgName [
    "vscode"
    "vscode-insiders"
  ];

  inherit (import ./vscode-ext-groups.nix { inherit pkgs install-remote; }) all;
in
pkgs.vscode-with-extensions.override {
  vscode = pkgs.${pkgName};
  vscodeExtensions = all;
}

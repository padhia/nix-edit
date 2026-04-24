{ pkgs, wrappers }:

let
  languages = {
    language-servers = {
      pyrefly = {
        command = "pyrefly";
        args = [ "lsp" ];
        except-features = [ "format" ];
      };
      ruff = {
        command = "ruff";
        args = [ "server" ];
        only-features = [ "format" ];
      };
    };
    language = import ./language.nix { inherit pkgs; };
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

  package =
    (wrappers.wrapperModules.helix.apply {
      inherit pkgs settings languages;
    }).wrapper;
in
pkgs.symlinkJoin {
  name = "my-helix";
  paths = [
    package
    pkgs.ruff
    pkgs.metals
    pkgs.scalafmt
    pkgs.pyrefly
  ];

  inherit (pkgs.helix) meta;

  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/hx --prefix PATH : $out/bin
  '';
}

{ pkgs, wrappers }:

let
  kclLSP = pkgs.lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.kcl-language-server;

  languages = {
    language-server = {
      pyrefly = {
        command = "pyrefly";
        args = [ "lsp" ];
      };
      ruff = {
        command = "ruff";
        args = [ "server" ];
      };
    }
    // pkgs.lib.optionalAttrs kclLSP {
      kcl-lsp = {
        command = "kcl-language-server";
        args = [ ];
      };
    };

    language = import ./language.nix { inherit pkgs kclLSP; };
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
    keys.normal.X = "select_line_above";
  };

  kclGrammar = pkgs.vimPlugins.nvim-treesitter-parsers.kcl.origGrammar;

  extraFiles = [
    {
      name = "runtime/grammars/kcl.so";
      file.path = "${kclGrammar}/parser";
    }
    {
      name = "runtime/queries/kcl/highlights.scm";
      file.path = "${kclGrammar.src}/queries/highlights.scm";
    }
  ];

  package =
    (wrappers.wrapperModules.helix.apply {
      inherit
        pkgs
        settings
        languages
        extraFiles
        ;
    }).wrapper;

  pkl-formatter = pkgs.writeShellScriptBin "pkl-formatter" ''
    ${pkgs.pkl}/bin/pkl format - || {
      code=$?
      [ "$code" -eq 11 ] && exit 0 || exit "$code"
    }
  '';

  kcl-formatter = pkgs.writeShellScriptBin "kcl-formatter" ''
    tmp=$(mktemp --suffix=.k)
    trap 'rm -f "$tmp"' EXIT
    cat > "$tmp"
    ${pkgs.kcl}/bin/kcl fmt "$tmp" >/dev/null
    cat "$tmp"
  '';
in
pkgs.symlinkJoin {
  name = "my-helix";
  paths = [
    package
    pkgs.nixd
    pkgs.ruff
    pkgs.metals
    pkgs.scalafmt
    pkgs.pyrefly
    pkgs.pkl-lsp
    pkl-formatter
    pkgs.kcl
    kcl-formatter
  ]
  ++ pkgs.lib.optional kclLSP pkgs.kcl-language-server;

  inherit (pkgs.helix) meta;

  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/hx --prefix PATH : $out/bin
  '';
}

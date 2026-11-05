{ pkgs, ... }:
let
  kclLSP = pkgs.lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.kcl-language-server;

  vim = {
    viAlias = true;
    vimAlias = true;

    autocomplete.nvim-cmp.enable = true;
    autopairs.nvim-autopairs.enable = true;
    binds.whichKey.enable = true;
    comments.comment-nvim.enable = true;
    formatter.conform-nvim.enable = true;
    filetree.neo-tree.enable = true;
    git.enable = true;
    git.gitsigns.codeActions.enable = true;
    git.gitsigns.enable = true;
    lsp.enable = true;
    lsp.formatOnSave = true;
    options.wrap = false;
    options.formatexpr = "v:lua.require'conform'.formatexpr()";
    statusline.lualine.enable = true;
    statusline.lualine.integrations.breadcrumbs.nvim-navic.enable = true;
    telescope.enable = true;
    utility.surround.enable = true;
    visuals.indent-blankline.enable = true;
    visuals.rainbow-delimiters.enable = true;

    extraPlugins.ayu-vim = {
      package = pkgs.vimPlugins.ayu-vim;
      setup = ''
        vim.g.ayucolor = "mirage"
      '';
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>F";
        action = "<cmd>lua require('conform').format({ async = true })<CR>";
        silent = true;
        desc = "Format document";
      }
    ];

    theme = {
      enable = true;
      name = "gruvbox";
      style = "dark";
      transparent = false;
    };

    languages = {
      enableTreesitter = true;
      enableFormat = true;

      scala.enable = true;

      nix = {
        enable = true;
        lsp.enable = true;
        lsp.servers = [ "nixd" ];
        format.enable = true;
        format.type = [ "nixfmt" ];
      };

      python = {
        enable = true;
        lsp.enable = true;
        lsp.servers = [ "pyrefly" ];
        format.enable = true;
        format.type = [ "ruff" ];
      };

      sql = {
        enable = true;
        treesitter.enable = true;
        lsp.enable = false;
        format.enable = false;
      };

      yaml.enable = true;
      toml.enable = true;
      bash.enable = true;
    };

    filetype.extension.k = "kcl";

    lsp.servers = {
      pkl = {
        enable = true;
        cmd = [ (pkgs.lib.getExe pkgs.pkl-lsp) ];
        filetypes = [
          "pkl"
          "pcf"
        ];
        root_markers = [
          "PklProject"
          ".git"
        ];
      };
    }
    // pkgs.lib.optionalAttrs kclLSP {
      kcl = {
        enable = true;
        cmd = [ (pkgs.lib.getExe pkgs.kcl-language-server) ];
        filetypes = [ "kcl" ];
        root_markers = [
          "kcl.mod"
          "kcl.yaml"
          ".git"
        ];
      };
    };

    formatter.conform-nvim.setupOpts = {
      formatters_by_ft = {
        kcl = [ "kcl" ];
        pkl = [ "pkl" ];
      };
      formatters = {
        kcl.command = pkgs.lib.getExe pkgs.kcl;
        pkl.command = pkgs.lib.getExe pkgs.pkl;
      };
    };

    treesitter.grammars = with pkgs.vimPlugins.nvim-treesitter-parsers; [
      pkl
      kcl
    ];
  };
in
{
  inherit vim;
}

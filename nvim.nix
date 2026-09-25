{ pkgs, ... }: {
  vim.viAlias = true;
  vim.vimAlias = true;

  vim.autocomplete.nvim-cmp.enable = true;
  vim.autopairs.nvim-autopairs.enable = true;
  vim.binds.whichKey.enable = true;
  vim.comments.comment-nvim.enable = true;
  vim.filetree.neo-tree.enable = true;
  vim.git.enable = true;
  vim.git.gitsigns.codeActions.enable = true;
  vim.git.gitsigns.enable = true;
  vim.lsp.enable = true;
  vim.lsp.formatOnSave = true;
  vim.statusline.lualine.enable = true;
  vim.statusline.lualine.integrations.breadcrumbs.nvim-navic.enable = true;
  vim.telescope.enable = true;
  vim.utility.surround.enable = true;
  vim.visuals.indent-blankline.enable = true;
  vim.visuals.rainbow-delimiters.enable = true;

  vim.extraPlugins.ayu-vim.package = pkgs.vimPlugins.ayu-vim;

  vim.theme = {
    enable = true;
    name = "gruvbox";
    style = "dark";
    transparent = false;
  };

  vim.languages = {
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

  vim.treesitter.grammars = [ pkgs.vimPlugins.nvim-treesitter-parsers.pkl ];
}

{
  viAlias = true;
  vimAlias = true;

  colorschemes.gruvbox.enable = true;
  colorschemes.ayu.enable = true;
  editorconfig.enable = true;

  lsp.servers = {
    pyright.enable = true;
    metals.enable = true;
    ansiblels.enable = false;
    erlang.enable = false;
  };

  globals = {
    mapleader = " ";
    maplocalleader = " ";
  };

  opts = {
    autoindent     = true;
    background     = "dark";
    backspace      = "indent,eol,start";
    backup         = false;
    clipboard      = "unnamedplus";
    diffopt        = "filler,context:25,icase,iwhite,vertical";
    history        = 50;
    hlsearch       = true;
    incsearch      = true;
    laststatus     = 2;
    list           = true;
    listchars      = "tab:  ";
    mouse          = "a";
    number         = true;
    relativenumber = true;
    selectmode     = "";
    splitright     = true;
    termguicolors  = true;
    undofile       = true;
    virtualedit    = "block";
    wrap           = false;
  };

  plugins = {
    bufferline.enable = true;
    web-devicons.enable = true;
    neo-tree.enable = true;
    gitsigns.enable = true;
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>e";
      action = "<cmd>Neotree toggle<cr>";
      options.desc = "Toggle Neotree";
    }
  ];
}

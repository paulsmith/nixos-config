{ pkgs, ... }: {
  programs.vim = {
    enable = true;

    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      zig-vim
      vim-go
      nerdtree
      fzf-vim
      LanguageClient-neovim
      emmet-vim
    ];

    settings = {
      background = "dark";
      copyindent = true;
      expandtab = true;
      hidden = true;
      history = 1000;
      ignorecase = true;
      modeline = true;
      mouse = "a";
      mousemodel = "extend";
      number = true;
      relativenumber = true;
      shiftwidth = 4;
      smartcase = true;
      tabstop = 4;
    };

    extraConfig = builtins.readFile ./vimrc;
  };
}

# Plug 'gregsexton/MatchTag'

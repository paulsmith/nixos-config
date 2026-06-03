{
  dotfiles,
  lib,
  pkgs,
  ...
}:

let
  homeDirectory = "/home/paul";

  gitConfig = builtins.replaceStrings [ "/Users/paul" ] [ homeDirectory ] (
    builtins.readFile "${dotfiles}/dot_config/git/config"
  );

  jjConfig = builtins.replaceStrings [ "{{ .email | quote }}" ] [ "\"paulsmith@pobox.com\"" ] (
    builtins.readFile "${dotfiles}/dot_config/jj/config.toml.tmpl"
  );

  nvimInit = ''
    vim.g.mapleader = ","
    vim.g.maplocalleader = ","

    vim.opt.autoindent = true
    vim.opt.background = os.getenv("NVIM_BACKGROUND") == "Light" and "light" or "dark"
    vim.opt.breakindent = true
    vim.opt.colorcolumn = "80"
    vim.opt.cursorline = true
    vim.opt.expandtab = true
    vim.opt.ignorecase = true
    vim.opt.inccommand = "split"
    vim.opt.list = true
    vim.opt.listchars = { tab = "> ", trail = ".", nbsp = "+" }
    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.scrolloff = 8
    vim.opt.shiftwidth = 4
    vim.opt.signcolumn = "yes"
    vim.opt.smartcase = true
    vim.opt.softtabstop = 4
    vim.opt.tabstop = 4
    vim.opt.termguicolors = true
    vim.opt.undofile = true

    vim.g.loaded_node_provider = 0
    vim.g.loaded_perl_provider = 0
    vim.g.loaded_python3_provider = 0
    vim.g.loaded_ruby_provider = 0
    vim.g.ftplugin_sql_omni_key = "<C-q>"

    vim.cmd("syntax enable")
    vim.cmd("filetype plugin indent on")

    vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to window to left" })
    vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to window below" })
    vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to window above" })
    vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to window to right" })
    vim.keymap.set("n", "<F5>", "<cmd>make<cr>", { desc = "Make" })
    vim.keymap.set("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix list" })
    vim.keymap.set("n", "]q", "<cmd>cnext<cr>", { desc = "Next on quickfix list" })
    vim.keymap.set("n", "[q", "<cmd>cprevious<cr>", { desc = "Previous on quickfix list" })
    vim.keymap.set("n", "<leader>q", "vip:j<cr>:.!fmt -w 80<cr>", { desc = "Format paragraph" })
    vim.keymap.set("n", "<leader><space>", "<cmd>nohlsearch<cr>", { desc = "Clear search" })
    vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search" })
    vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

    vim.api.nvim_create_autocmd("TextYankPost", {
      group = vim.api.nvim_create_augroup("agent_vm", { clear = true }),
      callback = function()
        vim.highlight.on_yank()
      end,
    })

    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
      pattern = "*.gs",
      command = "set ft=html",
    })
  '';
in
{
  home = {
    username = "paul";
    homeDirectory = homeDirectory;
    stateVersion = "26.05";

    sessionVariables = {
      EDITOR = "nvim";
      SVDIR = "$HOME/service";
      FONTCONFIG_FILE = "$HOME/.config/fontconfig/fonts.conf";
    };

    file = {
      ".config/git/config".text = gitConfig;
      ".config/git/ignore".source = "${dotfiles}/dot_config/git/ignore";
      ".config/jj/config.toml".text = jjConfig;
      ".config/bat/config".source = "${dotfiles}/dot_config/bat/config";
      ".config/fontconfig/fonts.conf".source = "${dotfiles}/dot_config/fontconfig/fonts.conf";
      ".config/nvim/init.lua".text = nvimInit;
      ".inputrc".source = "${dotfiles}/dot_inputrc";
      ".sqliterc".source = "${dotfiles}/dot_sqliterc";
      ".gitattributes".source = "${dotfiles}/dot_gitattributes";
      ".gitignore_global".source = "${dotfiles}/dot_gitignore_global";
      ".dotfiles/reference/bashrc".source = "${dotfiles}/dot_bashrc";
      ".dotfiles/reference/bash_profile".source = "${dotfiles}/dot_bash_profile";
    };

    activation.removeLegacyNvimPluginSymlinks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      for path in "$HOME/.config/nvim/lazy-lock.json" "$HOME/.config/nvim/lua"; do
        if [ -L "$path" ]; then
          target="$(${pkgs.coreutils}/bin/readlink "$path")"
          case "$target" in
            /nix/store/*) ${pkgs.coreutils}/bin/rm "$path" ;;
          esac
        fi
      done
    '';
  };

  programs = {
    home-manager.enable = true;

    bash = {
      enable = true;
      shellAliases = {
        gau = "git add -u";
        gc = "git commit";
        gco = "git checkout";
        gd = "git diff";
        gdc = "git diff --cached";
        gs = "git status";
        ll = "ls -l";
        ls = "ls --color=auto";
        vi = "nvim";
        view = "nvim -R";
        vim = "nvim";
        vimdiff = "nvim -d";
      };
      profileExtra = ''
        export PATH="$HOME/.local/bin:$HOME/go/bin:$HOME/.cargo/bin:$PATH"
      '';
      initExtra = ''
        [[ $- == *i* ]] || return

        export CDPATH=".:$HOME/projects:$HOME/.config"

        if command -v fzf >/dev/null; then
          eval "$(fzf --bash)"
        fi

        if command -v direnv >/dev/null; then
          eval "$(direnv hook bash)"
        fi

        if command -v jj >/dev/null; then
          source <(jj util completion bash)
        fi

        PS1='\h:\W \$ '
      '';
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  xdg.enable = true;

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    bashInteractive
  ];
}

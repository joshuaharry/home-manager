{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "joshuahoeflich";
  home.homeDirectory = "/Users/joshuahoeflich";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.direnv
    pkgs.eza
    pkgs.lf
    pkgs.gh
    pkgs.ripgrep
    pkgs.nixpkgs-fmt

    # Node JS
    # NOTE: We can't have a pseudo-global Node JS dependency, because that
    # breaks autoformatting with prettier in Neovim. Instead, set it to the
    # shell.nix file of the project you're developing.
    pkgs.typescript-language-server
    pkgs.vscode-langservers-extracted
    pkgs.nodePackages.prettier

    # Python
    pkgs.python313
    pkgs.pyright
    pkgs.ruff
    pkgs.uv
  ];

  # Configure neovim
  programs.neovim = {
    enable = true;

    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      # Fuzzy searching
      telescope-nvim
      # Autoformatting, by Google
      vim-codefmt
      # Autopairs
      lexima-vim
      # Close HTML tags (e.g., <p> -> <p></p>)
      vim-closetag
      # TypeScript
      yats-vim
      # Treesitter
      nvim-treesitter

      # Autocomplete
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      nvim-snippy
      cmp-snippy
    ];

    # Home manager expects vimscript, not lua.
    extraConfig = ''
            " Always display line numbers.
            set number

            set expandtab        " Use spaces instead of tabs
            set shiftwidth=4     " Number of spaces to use for each step of (auto)indent
            set softtabstop=4    " Number of spaces a <Tab> counts for while editing

            " Set closetag file types.
            let g:closetag_filetypes = "astro,eruby,template,typescriptreact,javascriptreact,vue,html,heex"

            " Set the leader key to space.
            let mapleader = " "
            let maplocalleader = ","

            " Highlight trailing whitespace
            highlight ExtraWhitespace ctermbg=red guibg=red
            match ExtraWhitespace /\s\+$/

            " Automatically refresh the highlight when switching buffers or editing
            autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
            autocmd InsertLeave * match ExtraWhitespace /\s\+$/
            autocmd InsertEnter * match none

            " Add some nice keybindings.
            nnoremap <silent> q :q<CR>
            nnoremap <silent> <leader>w <C-w><C-w>
            nnoremap <silent> <leader>j :bnext<CR>
            nnoremap <silent> <leader>k :bprev<CR>
            nnoremap <silent> <leader>f za

            " Telescope
            nnoremap <silent> <leader>sf <cmd>lua require('telescope.builtin').find_files()<CR>
            nnoremap <silent> <leader>sg <cmd>lua require('telescope.builtin').live_grep()<CR>

            " Formatting
            nnoremap <silent> <leader>p :FormatCode<CR>
            augroup autoformat_settings
                autocmd FileType bzl AutoFormatBuffer buildifier
                autocmd FileType c,cpp,proto,arduino AutoFormatBuffer clang-format
                autocmd FileType clojure AutoFormatBuffer cljstyle
                autocmd FileType dart AutoFormatBuffer dartfmt
                autocmd FileType elixir,eelixir,heex AutoFormatBuffer mixformat
                autocmd FileType go AutoFormatBuffer gofmt
                autocmd FileType haskell AutoFormatBuffer ormolu
                " Alternative for web languages: prettier
                autocmd FileType html,css,scss,less,json AutoFormatBuffer prettier
                autocmd FileType markdown AutoFormatBuffer prettier
                autocmd FileType javascript,typescript,typescriptreact,vue AutoFormatBuffer prettier
                autocmd FileType python AutoFormatBuffer ruff
                autocmd FileType ruby AutoFormatBuffer rubocop
                autocmd FileType rust AutoFormatBuffer rustfmt
                autocmd FileType vue AutoFormatBuffer prettier
            augroup END


            lua << EOF
      local lspconfig = require('lspconfig')
      lspconfig.pyright.setup({})
      lspconfig.ts_ls.setup({})

      local cmp = require("cmp")

      -- Set up jump to definition
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { noremap = true, silent = true })

      -- Make error messages appear inside popups
      vim.o.updatetime = 250

      vim.diagnostic.config({
        virtual_text = true,
        float = {
          source = "always",
          width = 80,
          border = border,
        },
      })

      vim.api.nvim_create_autocmd({
        "CursorHold",
        "CursorHoldI",
      }, {
        callback = function()
          if not cmp.visible() then
            vim.diagnostic.open_float(nil, { focus = false })
          end
        end,
      })

      cmp.setup({
        snippet = {
          expand = function(args)
            require("snippy").expand_snippet(args.body)
          end,
        },
        completion = {
          autocomplete = false,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-n>"] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_next_item()
            else
              cmp.complete()
            end
          end),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-space>"] = cmp.mapping.complete(),
          ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
          -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "snippy" },
          { name = "path" },
          { name = "buffer" },
        })
      })

      EOF
    '';
  };

  # Configure git
  programs.git = {
    enable = true;
    userEmail = "joshuaharry411@icloud.com";
    userName = "Joshua Hoeflich";
    aliases = {
      "co" = "checkout";
      "sl" = "log --pretty=format:'%C(bold cyan)%h%Creset -%C(white)%d%Creset %s %Cgreen(%cr) %C(yellow)<%an>%Creset' --abbrev-commit -n 10";
      "b" = "branch";
      "cob" = "checkout -b";
      "pu" = "push";
      "poh" = "!git push --set-upstream origin";
    };

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };

  };

  # Configure kitty
  programs.kitty = {
    enable = true;
    extraConfig = ''
      map cmd+1 goto_tab 1
      map cmd+2 goto_tab 2
      map cmd+3 goto_tab 3
      map cmd+4 goto_tab 4
      map cmd+5 goto_tab 5
      map cmd+6 goto_tab 6
      map cmd+7 goto_tab 7
      map cmd+8 goto_tab 8
      map cmd+9 goto_tab 9
      map cmd+n send_text all \x0e
      map cmd+p send_text all \x10
    '';
  };

  # Configure zsh
  programs.zsh = {
    enable = true;
    plugins = [
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
      }
    ];
    initExtra = ''
      autoload -Uz vcs_info
      precmd() { vcs_info }
      zstyle ":vcs_info:git:*" formats "%b "
      setopt PROMPT_SUBST

      # Set the prompt. This is much harder than it should be because we
      # have to account for the fact that everything is in a single nix
      # file.
      PROMPT="%F{green}%@%f %F{blue}%~%f %F{red}''$''\{vcs_info_msg_0_''\}%f''$ "

      # Set some nice aliases.
      alias aliases='nvim ~/.config/home-manager/home.nix'
      alias c='clear'
      alias g='git'
      alias home='nvim ~/.config/home-manager/home.nix'
      alias vimrc='nvim ~/.config/home-manager/home.nix'
      alias hs='home-manager switch'
      alias switch='home-manager switch'
      alias l='eza -l'
      alias lh='eza -l -a'
      alias ls='eza -l'
      alias reload='home-manager switch'
      alias rimraf='rm -rf'

      # Actually enable the packages installed above
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      setopt autocd
      eval "$(direnv hook zsh)"
    '';
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/joshuahoeflich/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

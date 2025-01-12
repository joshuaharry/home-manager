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
    pkgs.neovim
    pkgs.direnv
    pkgs.eza
    pkgs.lf
    pkgs.gh

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Configure git
  programs.git = {
    enable = true;
    userEmail = "joshuaharry411@icloud.com";
    userName = "Joshua Hoeflich";
    aliases = {
      "co"  = "checkout";
      "sl"  = "log --pretty=format:'%C(bold cyan)%h%Creset -%C(white)%d%Creset %s %Cgreen(%cr) %C(yellow)<%an>%Creset' --abbrev-commit -n 10";
      "b"   = "branch";
      "cob" = "checkout -b";
      "pu"  = "push";
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
      map cmd+n send_text normal,application \x0e
      map cmd+p send_text normal,application \x10
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
        src  = pkgs.zsh-autosuggestions;
      }
    ];
    initExtra = ''
      autoload -Uz vcs_info
      precmd() { vcs_info }
      zstyle ":vcs_info:git:*" formats "%b "
      setopt PROMPT_SUBST

      # Extremely tricky prompt substitution magic.
      PROMPT="%F{green}%*%f %F{blue}%~%f %F{red}''$''\{vcs_info_msg_0_''\}%f''$ "

      # Set some nice aliases.
      alias aliases='nvim ~/.config/home-manager/home.nix'
      alias c='clear'
      alias g='git'
      alias home='nvim ~/.config/home-manager/home.nix'
      alias hs='home-manager switch'
      alias l='eza -l'
      alias lh='eza -l- a'
      alias ls='eza -l'
      alias reload='home-manager switch'
      alias rimraf='rm -rf'
      alias v='nvim'
      alias vi='nvim'
      alias vim='nvim'

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

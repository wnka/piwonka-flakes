{ pkgs, lib, ... }: {
  # Don't change this when you change package input. Leave it alone.
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;

  # specify my home-manager configs
  home.packages = with pkgs; [
    awscli2
    btop
    # curl # this was messing up internal websites on my work laptop
    delta
    difftastic
    du-dust
    entr
    eza
    fd
    git-crypt
    gnupg
    hugo
    hyperfine
    imagemagick
    jq
    nixfmt
    mosh
    oha
    pam-reattach
    pandoc
    ripgrep
    rustup
    trippy
    vegeta
    zstd
  ];
  home.sessionVariables = {
    PAGER = "bat";
    EDITOR = "emacs";
  };

  home.file.".inputrc".source = ./files/inputrc;
  home.file.".gitconfig".source = ./files/gitconfig;

  home.activation.installTerminfo = lib.hm.dag.entryAfter ["writeBoundary"] ''
    tic -x -o ~/.terminfo ${./files/terminfo}
  '';

  programs.git = {
    enable = true;
  };

  programs.fish = {
    enable = true;
    shellInit = ''
      # End Nix
      # Clear the greeting
      set -g fish_greeting
      fzf_configure_bindings

      set -U pure_color_current_directory magenta
    '';
    plugins = [
      { name = "pure"; src = pkgs.fishPlugins.pure.src; }
      { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
      { name = "autopair"; src = pkgs.fishPlugins.autopair.src; }
      # Need this when using Fish as a default macOS shell in order to pick
      # up ~/.nix-profile/bin
      {
        name = "nix-fish";
        src = pkgs.fetchFromGitHub {
          owner = "kidonng";
          repo = "nix.fish";
          rev = "ad57d970841ae4a24521b5b1a68121cf385ba71e";
          sha256 = "GMV0GyORJ8Tt2S9wTCo2lkkLtetYv0rc19aA5KJbo48=";
        };
      }
    ];
    shellAliases = {
      ls = "eza --group-directories-first --color-scale all --icons";
      cat = "bat";
      less = "bat";
      doomup = "~/.emacs.d/bin/doom -! upgrade";
      doomsync = "~/.emacs.d/bin/doom sync";
      du = "dust";
      gst = "git status";
      gco = "git checkout";
      gb = "git branch";
      gd = "git diff";
      glg = "git log";
      ll = "eza --group-directories-first --color-scale all --icons -lbG --git";
      tma = "tmux new-session -A -s main";
    };
  };
  programs.bat = {
    enable = true;
    config = { theme = "ansi"; };
    extraPackages = with pkgs.bat-extras; [
      batgrep
      batdiff
      batman
      batpipe
    ];
  };
  programs.fzf = {
    enable = true;
    # False because I want to use the fzf-fish plugin instead
    enableFishIntegration = false;
  };
  programs.zoxide = { enable = true; };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.kitty = {
    enable = true;
    settings = {
      disable_ligatures = "always";
      cursor_shape = "block";
      font_family = "JetBrainsMono Nerd Font Light";
      font_size = "16.0";
      modify_font = "cell_width 90%";
      cursor_blink_interval = "0";
      map = "kitty_mod+minus no_op";
      macos_option_as_alt = "yes";
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_type = "slanted";
      window_margin_width = "2";
    };
    theme = "shadotheme";
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    sensibleOnTop = false;
    prefix = "`";
    keyMode = "emacs";
    extraConfig = ''
      # Split panes with \ and -
      bind \\ split-window -h
      bind - split-window -v
      unbind '"'
      unbind %

      bind r source ~/.config/tmux/tmux.conf

      set -g default-terminal "xterm-256color"
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
      set-environment -g COLORTERM "truecolor"

      set-option -g mouse on
    '';

    plugins = with pkgs; [
      tmuxPlugins.tmux-fzf
      tmuxPlugins.prefix-highlight
      tmuxPlugins.fzf-tmux-url
      tmuxPlugins.extrakto
      # https://draculatheme.com/tmux
      {
        plugin = tmuxPlugins.dracula;
        extraConfig = ''
        set -g @dracula-show-battery true
        set -g @dracula-show-powerline false
        set -g @dracula-refresh-rate 10
        set -g @dracula-show-weather false
        set -g @dracula-plugins "battery time"
        set -g @dracula-show-left-icon session
      '';
      }
    ];
  };
}

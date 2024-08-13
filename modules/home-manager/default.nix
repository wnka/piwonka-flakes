{ pkgs, lib, ... }: {

  # Don't change this when you change package input. Leave it alone.
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;

  # specify my home-manager configs
  home.packages = with pkgs; [
    atuin
    awscli2
    # aws-sam-cli # busted
    bandwhich
    btop
    cargo-lambda
    cmake
    # curl # this was messing up internal websites on my work laptop
    delta
    devenv
    difftastic
    du-dust
    entr
    eza
    fd
    fio
    git-crypt
    gnugrep
    gnupg
    hyperfine
    imagemagick
    iperf
    jq
    nixfmt-rfc-style
    mermaid-cli
    mosh
    nodePackages.aws-cdk
    oha
    pandoc
    pv
    rage
    ripgrep
    rustup
    tmuxinator
    trippy
    vegeta
    xh
    yaml-language-server
    yazi
    zellij
    zjstatus
    zstd
  ];
  home.sessionVariables = {
    PAGER = "bat";
    EDITOR = "emacsclient -nw";
  };

  home.file.".inputrc".source = ./files/inputrc;
  home.file.".gitconfig".source = ./files/gitconfig;

  xdg.configFile."tmuxinator".source = ./files/tmuxinator;

  xdg.configFile."alacritty/alacritty.toml".source = ./files/alacritty.toml;
  xdg.configFile."wezterm/wezterm.lua".source = ./files/wezterm/wezterm.lua;

  xdg.configFile."zellij/config.kdl".source = ./files/zellij/config.kdl;
  xdg.configFile."zellij/layouts/default.kdl".text = ''
layout {
    pane split_direction="vertical" {
        pane
    }

    pane size=1 borderless=true {
        plugin location="file://${pkgs.zjstatus}/bin/zjstatus.wasm" {
            hide_frame_for_single_pane "true"

            format_left  "{mode}#[fg=#89B4FA,bg=#181825,bold] {session}#[bg=#181825] {tabs}"
            format_right "{command_kubectx}#[fg=#424554,bg=#181825]::{command_kubens}{datetime}"
            format_space "#[bg=#181825]"

            mode_normal          "#[bg=#89B4FA] "
            mode_tmux            "#[bg=#ffc387] "
            mode_default_to_mode "tmux"

            tab_normal               "#[fg=#6C7086,bg=#181825] {index} {name} {fullscreen_indicator}{sync_indicator}{floating_indicator}"
            tab_active               "#[fg=#9399B2,bg=#181825,bold,italic] {index} {name} {fullscreen_indicator}{sync_indicator}{floating_indicator}"
            tab_fullscreen_indicator "□ "
            tab_sync_indicator       "  "
            tab_floating_indicator   "󰉈 "

            command_kubectx_command  "kubectx -c"
            command_kubectx_format   "#[fg=#6C7086,bg=#181825,italic] {stdout}"
            command_kubectx_interval "2"

            command_kubens_command  "kubens -c"
            command_kubens_format   "#[fg=#6C7086,bg=#181825]{stdout} "
            command_kubens_interval "2"

            datetime          "#[fg=#9399B2,bg=#181825] {format} "
            datetime_format   "%A, %d %b %Y %H:%M"
            datetime_timezone "America/Los_Angeles"
        }
    }
}
  '';

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

      # clear LS_COLORS
      set -e LS_COLORS

      # 'done' plugin doesn't handle kitty on Mac well because it prioritizes kitty over terminal-notifier
      # so let's set our own notification command
      set -g __done_notification_command "echo \"\$message\" | terminal-notifier -title \"\$title\""

      atuin init fish | source
    '';
    plugins = [
      { name = "done"; src = pkgs.fishPlugins.done.src; }
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
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = builtins.fromTOML (builtins.unsafeDiscardStringContext(builtins.readFile ./files/starship.toml));
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
      font_size = "15.0";
      modify_font = "cell_width 90%";
      cursor_blink_interval = "0";
      map = "kitty_mod+minus no_op";
      macos_option_as_alt = "yes";
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_type = "slanted";
      active_tab_foreground = "#fff";
      active_tab_background = "#1a659e";
      active_tab_font_style = "bold-italic";
      inactive_tab_foreground = "#efefd0";
      inactive_tab_background = "#011627";
      inactive_tab_font_style = "normal";
      window_margin_width = "2";
      copy_on_select = "yes";
    };
    theme = "Catppuccin-Mocha";
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
      tmuxPlugins.yank
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

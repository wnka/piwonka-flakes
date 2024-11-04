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
    eternal-terminal
    eza
    fd
    fio
    git-crypt
    gnugrep
    gnupg
    helix
    hyperfine
    imagemagick
    iperf
    jq
    lazygit
    nixfmt-rfc-style
    marksman
    mermaid-cli
    # mosh
    # nodePackages.aws-cdk
    oha
    pandoc
    pv
    rage
    ripgrep
    rustup
    time
    trippy
    vegeta
    xh
    yaml-language-server
    yazi
    zellij
    zstd
  ];
  home.sessionVariables = {
    PAGER = "bat";
    EDITOR = "hx";
  };

  home.file.".inputrc".source = ./files/inputrc;
  home.file.".gitconfig".source = ./files/gitconfig;

  xdg.configFile."wezterm".source = ./files/wezterm;
  xdg.configFile."helix".source = ./files/helix;
  xdg.configFile."zellij".source = ./files/zellij;
  
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
      utime = "command time"; # use the Linux time cmd, not the fish builtin
      lg = "lazygit";
      lz = "lazygit";
      zj = "zellij";
      jz = "zellij";
      h = "hx";
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
}

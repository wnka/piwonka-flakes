{ pkgs, lib, ... }: {

  # Don't change this when you change package input. Leave it alone.
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;

  # Without this I get lang/local errors on ssh/login
  # https://github.com/nix-community/home-manager/issues/432
  programs.man.enable = false;
  home.extraOutputsToInstall = [ "man" ];

  # specify my home-manager configs
  home.packages = with pkgs; [
    atuin
    awscli2
    btop
    # curl # this was messing up internal websites on my work laptop
    delta
    devenv
    difftastic
    du-dust
    entr
    eternal-terminal
    eza
    fd
    fx
    git-crypt
    gnugrep
    gnupg
    helix
    iperf
    jq
    lazygit
    markdown-oxide
    marksman
    mermaid-cli
    mosh
    oha
    pandoc
    pv
    ripgrep
    ssm-session-manager-plugin
    taskwarrior3
    taskwarrior-tui
    television
    time
    xan
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
  
  xdg.configFile."ghostty".source = ./files/ghostty;
  xdg.configFile."helix".source = ./files/helix;
  xdg.configFile."zellij".source = ./files/zellij;
  xdg.configFile."yazi".source = ./files/yazi;
  xdg.configFile."nix".source = ./files/nix;

  
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

      function wezcopy
        read -z clip_stuff
        printf "\033]1337;SetUserVar=%s=%s\007" wez_copy (echo -n "$clip_stuff" | base64 -w 0)
      end

      atuin init fish | source
    '';
    plugins = [
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
      catp = "bat --style=plain";
      less = "bat";
      du = "dust";
      gst = "git status";
      gco = "git checkout";
      gb = "git branch";
      gd = "git diff";
      gdt = "git difft";
      glg = "git log";
      ll = "eza --group-directories-first --color-scale all --icons -lbG --git";
      utime = "command time"; # use the Linux time cmd, not the fish builtin
      lg = "lazygit";
      lz = "lazygit";
      zj = "zellij";
      jz = "zellij";
      yy = "yazi";
      hh = "hx";
      # Using a pipe into fzf since fd will honor .gitignore
      hhf = "hx (fd --type f --strip-cwd-prefix | fzf)";
      curll = "curl -o /dev/null -w \"lookup:        %{time_namelookup}\nconnect:       %{time_connect}\nappconnect:    %{time_appconnect}\npretransfer:   %{time_pretransfer}\nredirect:      %{time_redirect}\nstarttransfer: %{time_starttransfer}\ntotal:         %{time_total}\n\"";
      # Taskwarrior helpers
      ttla = "task +LATEST";
      tt = "task";
      ttxn = "task context none";
      ttx = "task context";
      ttt = "commandline -rt (task rc.verbose:nothing ls | fzf --preview 'task {1}' | awk '{printf \"tt %s \", $1}')";
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

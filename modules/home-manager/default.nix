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
    codex
    # curl # this was messing up internal websites on my work laptop
    delta
    devenv
    difftastic
    dust
    dysk
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
    mergiraf
    mermaid-cli
    multitail
    oha
    pandoc
    posting
    pv
    ripgrep
    ssm-session-manager-plugin
    television
    # time
    xan
    xh
    yaml-language-server
    yazi
    zellij
    zstd
  ];
  home.sessionVariables = {
    PAGER = "bat --style=plain";
    EDITOR = "hx";
  };

  home.file.".inputrc".source = ./files/inputrc;
  
  xdg.configFile."git/attributes".source = ./files/git/gitattributes;
  
  xdg.configFile."ghostty".source = ./files/ghostty;
  xdg.configFile."lazygit".source = ./files/lazygit;
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

      # Opt out of Eternal Terminal telemetry b.s.
      set -x ET_NO_TELEMETRY true
      
      # I want Option-Backspace to just kill a word
      bind \e\x7F backward-kill-word

      # I want Ctrl-Space to undo
      bind ctrl-space undo

      # sed due to fish not allowing certain bind args anymore
      # https://github.com/atuinsh/atuin/issues/2940
      # Can remove laters
      atuin init fish | sed "s/-k up/up/g" | source 
    '';
    functions = {
      hhf = ''
          # Using fd + a pipe since that will honor .gitignore
          set -l selected_file (fd --type f --strip-cwd-prefix | fzf --height=50% --border=bold)
          if test -n "$selected_file"
            hx "$selected_file"
          end
    '';
    };
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
      catp = "bat";
      cat = "bat --style=plain";
      catn = "bat --style=plain --wrap=never";
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
      lg = "lazygit -ucd ~/.config/lazygit";
      lz = "lazygit -ucd ~/.config/lazygit";
      zj = "zellij";
      jz = "zellij";
      yy = "yazi";
      hh = "hx";
      curll = "curl -o /dev/null -w \"lookup:        %{time_namelookup}\nconnect:       %{time_connect}\nappconnect:    %{time_appconnect}\npretransfer:   %{time_pretransfer}\nredirect:      %{time_redirect}\nstarttransfer: %{time_starttransfer}\ntotal:         %{time_total}\n\"";
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

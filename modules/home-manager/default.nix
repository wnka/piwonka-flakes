{ pkgs, ... }: {
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
    pandoc
    ripgrep
    rustup
    trippy
    vegeta
    vivid
    zstd
  ];
  home.sessionVariables = {
    PAGER = "bat";
    EDITOR = "emacs";
  };

  home.file.".inputrc".source = ./files/inputrc;
  home.file.".gitconfig".source = ./files/gitconfig;

  programs.git = {
    enable = true;
  };

  programs.fish = {
    enable = true;
    shellInit = ''
      # End Nix
      # Clear the greeting
      set -g fish_greeting

      export LS_COLORS="$(vivid generate nord)"

      fzf_configure_bindings
    '';
    plugins = [
      { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
      # Need this when using Fish as a default macOS shell in order to pick
      # up ~/.nix-profile/bin
      {
        name = "nix-env";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
          sha256 = "vi4sYoI366FkIonXDlf/eE2Pyjq7E/kOKBrQS+LtE+M=";
        };
      }
    ];
    functions = {
      bimg = ''
      set output_links
      for i in $argv
          set filename (basename $i)
          set rootname (echo $filename | sed 's/\.[^.]*$//')
          set output_filename "$rootname.jpg"
          set link_path "/images/$output_filename"
          set -a output_links $link_path
          set output_filepath "/Users/piwonka/code/pdp80-blog/static/images/$output_filename"
          echo "Processing: $filename" 1>&2
          convert $i -auto-orient -resize 1024x1024 -density 72 -sampling-factor 4:2:0 -strip -quality 85 -interlace JPEG -colorspace sRGB $output_filepath
      end

      for link in $output_links
          echo "{{< figure src=\"$link\" alt=\"ALT\" caption=\"CAPTION\" >}}"
      end
      '';
    };
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
    config = { theme = "Nord"; };
    extraPackages = with pkgs.bat-extras; [
      batgrep
      batdiff
      batman
      batpipe
    ];
  };
  programs.oh-my-posh = {
    enable = true;
    enableFishIntegration = true;
    settings = builtins.fromJSON (builtins.unsafeDiscardStringContext (builtins.readFile ./files/oh-my-posh-theme.omp.json));
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
      font_family = "Hack Nerd Font";
      font_size = "14.0";
      adjust_line_height = "8";
      cursor_blink_interval = "0";
      map = "kitty_mod+minus no_op";
      macos_option_as_alt = "yes";
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_type = "slanted";
    };
    theme = "Tokyo Night Storm";
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    sensibleOnTop = false;
    prefix = "`";
    keyMode = "emacs";
    plugins = with pkgs; [
      tmuxPlugins.tmux-fzf
      tmuxPlugins.prefix-highlight
      tmuxPlugins.copycat
      tmuxPlugins.fzf-tmux-url
      tmuxPlugins.extrakto
      tmuxPlugins.yank
      {
        plugin = tmuxPlugins.catppuccin;
        extraConfig = ''
          set -g @catppuccin_host "on"
          set -g @catppuccin_left_separator "█"
          set -g @catppuccin_right_separator "█"
          #set -g @catppuccin_window_tabs_enabled on
        '';
      }
    ];
    extraConfig = ''
      # Split panes with \ and -
      bind \\ split-window -h
      bind - split-window -v
      unbind '"'
      unbind %

      set -g default-terminal "xterm-256color"
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
      set-environment -g COLORTERM "truecolor"

      set-option -g mouse on
    '';
  };
}

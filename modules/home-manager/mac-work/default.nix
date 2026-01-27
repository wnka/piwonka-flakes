{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    pam-reattach
  ];
  
  xdg.configFile."git/config".source = ../files/git/gitconfig;
  xdg.configFile."git/config.work".source = ../files/git/gitconfig-work;
  home.file.".hammerspoon/init.lua".source = ../files/hammerspoon/init.lua;

  programs.fish = {
    shellInit = ''
      # Nix
      if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
        source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
      end
      fish_add_path /run/current-system/sw/bin
      fish_add_path /Applications/Emacs.app/Contents/MacOS/
      fish_add_path /opt/homebrew/bin
      fish_add_path /opt/homebrew/sbin
      fish_add_path /Users/piwonka/bin
      fish_add_path /Users/piwonka/.toolbox/bin
      fish_add_path /opt/homebrew/opt/llvm/bin
      fish_add_path /Users/piwonka/.cargo/bin
      set -x AWS_PROFILE work-personal
    '';
    functions = {
      sn = {
        body = ''
          set -l tab (zellij action dump-layout 2>/dev/null | sed -n 's/.*tab name="\([^"]*\)".*focus=true.*/\1/p')
          set -l msg "$argv"
          test -n "$tab" -a -n "$msg"; and set msg "[$tab] $msg"
          slack-mcp -m "$msg"
        '';
      };
      rsn = {
        body = ''
          set -l last_status $status
          set -l tab (zellij action dump-layout 2>/dev/null | sed -n 's/.*tab name="\([^"]*\)".*focus=true.*/\1/p')
          set -l label "$argv"
          if test -n "$tab" -a -n "$label"
              set label "[$tab] $label"
          else if test -n "$tab"
              set label "$tab"
          else if test -z "$label"
              set label (pwd)
          end
          if test $last_status -eq 0
              sn "✅ $label"
          else
              sn "❌ $label"
          end
        '';
      };
    };
    shellAliases = {
      funtime = "bash ~/bin/funtime.sh";
      worktime = "bash ~/bin/worktime.sh";
      nixs = "sudo darwin-rebuild switch --flake ~/code/nix/piwonka-flakes#mac-work";
      towiki = "pandoc --wrap=none -f org -t xwiki (fzf --preview 'bat --color=always --style=plain {}') | pbcopy";
      tomarkdown = "pandoc --wrap=none -f org -t markdown-smart (fzf --preview 'bat --color=always --style=plain {}') | pbcopy";
      bb = "brazil-build";
      bbr = "brazil-build release";
      dw = "~/bin/daywon -o ~/Documents/pdp-vault -l -a -c -t";
      et-8 = "et --terminal-path /home/piwonka/.nix-profile/bin/etterminal etc8i -p 2025";
    };
  };
}

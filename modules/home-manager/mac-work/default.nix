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
        body = ''slack-mcp -m "$argv"'';
      };
      rsn = {
        body = ''
          set -l last_status $status
          set -l label (test -n "$argv"; and echo "$argv - (pwd)"; or echo (pwd))
          if test $last_status -eq 0
              slack-mcp -m "✅ $label"
          else
              slack-mcp -m "❌ $label"
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

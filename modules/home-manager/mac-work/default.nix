{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    pam-reattach
  ];
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
    '';
    shellAliases = {
      e = "emacsclient -nc $argv; osascript -e 'tell application \"Emacs\" to activate'";
      ec = "TERM=xterm-emacs emacsclient -nw";
      funtime = "bash ~/bin/funtime.sh";
      worktime = "bash ~/bin/worktime.sh";
      nixs = "darwin-rebuild switch --flake ~/code/nix/piwonka-flakes#mac-work";
      towiki = "pandoc --wrap=none -f org -t xwiki (fzf --preview 'bat --color=always --style=plain {}') | pbcopy";
      tomarkdown = "pandoc --wrap=none -f org -t markdown-smart (fzf --preview 'bat --color=always --style=plain {}') | pbcopy";
      bb = "brazil-build";
      bbr = "brazil-build release";
      dw = "~/bin/daywon -o ~/Documents/pdp-vault -l -m -t -c";
      dwdsk = "~/bin/daywon -r devdsk-no-vpn";
      # Intel DevDesktop
      et-i = "et etdesktop";
      # Arm DevDesktop
      et-a = "et -p 2023 --terminal-path /home/piwonka/.nix-profile/bin/etterminal armdesktop";
    };
  };
}

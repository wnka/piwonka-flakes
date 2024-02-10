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
      fish_add_path /Users/piwonka/bin
    '';
    shellAliases = {
      e = "emacsclient -nc $argv; osascript -e 'tell application \"Emacs\" to activate'";
      ec = "TERM=xterm-emacs emacsclient -nw";
      nixs = "darwin-rebuild switch --flake ~/code/nix/piwonka-flakes#mac";
    };
  };
}

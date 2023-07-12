{ config, lib, pkgs, ... }:

{
  programs.fish = {
    shellInit = ''
      # Nix
      if test -e '/home/piwonka/.nix-profile/etc/profile.d/nix.fish'
        source '/home/piwonka/.nix-profile/etc/profile.d/nix.fish'
      end
      # End Nix
    '';
    shellAliases = {
      emacs-daemon = "TERM=xterm-emacs-leg command emacs --daemon";
      emacs-kill = "emacsclient -e '(kill-emacs)'";
      e = "TERM=xterm-emacs-leg command emacsclient -c -t";
      bb = "brazil-build";
      bbr = "brazil-build release";
      nixs = "home-manager switch -b backup";
    };
  };
}

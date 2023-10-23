{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    emacs
    util-linux # for chsh
  ];

  programs.fish = {
    shellInit = ''
      # Nix
      if test -e ~/.nix-profile/etc/profile.d/nix.fish
        source ~/.nix-profile/etc/profile.d/nix.fish
      end
      # End Nix
      fish_add_path /home/piwonka/.toolbox/bin
      fish_add_path /home/piwonka/.nix-profile/bin
      fish_add_path /nix/var/nix/profiles/default/bin
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

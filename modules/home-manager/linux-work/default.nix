{ config, lib, pkgs, configName, ... }:

{
  home.packages = with pkgs; [
    emacs
    util-linux # for chsh
    gcc
    glibc
    glib
    pinentry-curses
  ];

  home.file.".gnupg/gpg-agent.conf".source = ./files/gpg-agent.conf;
  
  programs.fish = {
    shellInit = ''
      # Nix
      if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
        source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
      end
      # End Nix
      fish_add_path /home/piwonka/.toolbox/bin
      fish_add_path /home/piwonka/.nix-profile/bin
      fish_add_path /nix/var/nix/profiles/default/bin
      fish_add_path /apollo/env/LambdaOperationalTools/bin
      fish_add_path /apollo/env/LambdaStatsOperationalTools/bin
      fish_add_path /apollo/env/envImprovement/bin
    '';
    shellAliases = {
      emacs-daemon = "TERM=xterm-emacs-leg command emacs --daemon";
      emacs-kill = "emacsclient -e '(kill-emacs)'";
      e = "TERM=xterm-emacs-leg command emacsclient -c -t";
      ec = "TERM=xterm-emacs-leg command emacsclient -c -t";
      bb = "brazil-build";
      bbr = "brazil-build release";
      nixs = "nix --experimental-features \"nix-command flakes\" build \".#homeConfigurations.${configName}.activationPackage\" && ./result/activate";
    };
  };
}

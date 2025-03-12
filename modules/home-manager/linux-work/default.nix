{ config, lib, pkgs, configName, ... }:

{
  home.packages = with pkgs; [
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

      # This will let you pipe things into "pbcopy" over ssh just like locally on a Mac!
      # https://blog.gripdev.xyz/2025/01/08/wezterm-easily-copy-text-or-send-notifications-to-local-machine-even-when-connected-via-ssh/
      function pbcopy
        read -z clip_stuff
        printf "\033]1337;SetUserVar=%s=%s\007" wez_copy (echo -n "$clip_stuff" | base64 -w 0)
      end
      
      fish_add_path /home/piwonka/.toolbox/bin
      fish_add_path /home/piwonka/.nix-profile/bin
      fish_add_path /nix/var/nix/profiles/default/bin
      fish_add_path /apollo/env/LambdaOperationalTools/bin
      fish_add_path /apollo/env/LambdaStatsOperationalTools/bin
      fish_add_path /apollo/env/envImprovement/bin
    '';
    shellAliases = {
      bb = "brazil-build";
      bbr = "brazil-build release";
      nixs = "nix build \".#homeConfigurations.${configName}.activationPackage\" && ./result/activate";
    };
  };
}

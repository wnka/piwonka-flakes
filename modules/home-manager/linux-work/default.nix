{ config, lib, pkgs, configName, ... }:

{
  home.packages = with pkgs; [
    dysk
    util-linux # for chsh
    gcc
    glibc
    glib
    go
    pinentry-curses
    uv
  ];

  home.file.".gnupg/gpg-agent.conf".source = ./files/gpg-agent.conf;
  home.file.".gitconfig".source = ../files/gitconfig;
  home.file.".gitconfig.work".source = ../files/gitconfig-work;
  
  programs.fish = {
    shellInit = ''
      # Nix
      if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
        source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
      end
      # End Nix

      fish_add_path /home/piwonka/.toolbox/bin
      fish_add_path /home/piwonka/.nix-profile/bin
      fish_add_path /home/piwonka/.cargo/bin
      fish_add_path /nix/var/nix/profiles/default/bin
      fish_add_path /apollo/env/LambdaOperationalTools/bin
      fish_add_path /apollo/env/LambdaStatsOperationalTools/bin
      fish_add_path /apollo/env/envImprovement/bin
      fish_add_path /home/piwonka/go/bin
      set -x AWS_PROFILE work-personal
      
      # Move .toolbox/bin to the front, since this is needed for rust-analyzer to work
      # right in brazil workspaces.
      fish_add_path --prepend --move /home/piwonka/.toolbox/bin
    '';
    shellAliases = {
      bb = "brazil-build";
      bbr = "brazil-build release";
      nixs = "nix build \".#homeConfigurations.${configName}.activationPackage\" && ./result/activate";
    };
  };
}

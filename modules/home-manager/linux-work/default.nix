{ config, lib, pkgs, configName, ... }:

{
  home.packages = with pkgs; [
    util-linux # for chsh
    cmake
    # gcc
    glibc
    glib
    go
    pinentry-curses
    uv
  ];

  home.file.".gnupg/gpg-agent.conf".source = ./files/gpg-agent.conf;
  xdg.configFile."git/config".source = ../files/git/gitconfig;
  xdg.configFile."git/config.work".source = ../files/git/gitconfig-work;
  
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
      fish_add_path /home/piwonka/.local/bin
      fish_add_path /home/piwonka/bin
      set -x AWS_PROFILE work-personal
      
      # Move .toolbox/bin to the front, since this is needed for rust-analyzer to work
      # right in brazil workspaces.
      fish_add_path --prepend --move /home/piwonka/.toolbox/bin
    '';
    functions = {
      slack-notify = {
        body = "slack-mcp -m \"$argv\"";
      };
    };
    shellAliases = {
      bb = "brazil-build";
      bbr = "brazil-build release";
      nixs = "nix build \".#homeConfigurations.${configName}.activationPackage\" && ./result/activate";
      dw = "mwinit -s -o";
    };
  };
}

{ config, lib, pkgs, ... }:

{
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
      fish_add_path /Users/piwonka/.toolbox/bin
    '';
    shellAliases = {
      e = "open -a /Applications/Emacs.app";
      vgm = "pushd ~/syncme/vgm; ./go.sh; popd";
      pick = "pushd ~/syncme/vgm; ./pick.sh; popd";
      funtime = "bash ~/bin/funtime.sh";
      worktime = "bash ~/bin/worktime.sh";
      nixs = "darwin-rebuild switch --flake ~/code/nix/piwonka-flakes#mac";
    };
  };
}

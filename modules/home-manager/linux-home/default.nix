{ config, lib, pkgs, configName, ... }:

{
  home.packages = with pkgs; [
    gcc13
    util-linux # for chsh
  ];

  programs.fish = {
    shellInit = ''
      # Nix
      if test -e ~/.nix-profile/etc/profile.d/nix.fish
        source ~/.nix-profile/etc/profile.d/nix.fish
      end
      # End Nix
      fish_add_path /run/current-system/sw/bin
    '';
    shellAliases = {
      nixs = "nix build \".#homeConfigurations.${configName}.activationPackage\" && ./result/activate";
    };
  };
}

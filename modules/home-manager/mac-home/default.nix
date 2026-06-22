{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    pam-reattach
  ];

  xdg.configFile."git/config".source = ../files/git/gitconfig-home;
  
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
      fish_add_path /opt/homebrew/opt/llvm/bin
      fish_add_path /Users/piwonka/.cargo/bin
    '';
    shellAliases = {
      nixs = "sudo darwin-rebuild switch --flake ~/code/nix/piwonka-flakes#mac";
      # Activate only the home-manager arm (no sudo, no system rebuild). Run `nixs` when you've also changed darwin-level config.
      nixh = "nix build ~/code/nix/piwonka-flakes#darwinConfigurations.mac.config.home-manager.users.piwonka.home.activationPackage --out-link /tmp/hm-result && /tmp/hm-result/activate";
    };
  };
}

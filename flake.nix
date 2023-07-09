{
  # This is totally under the influence of https://github.com/zmre/mac-nix-simple-example
  # YouTube video: https://www.youtube.com/watch?v=LE5JR4JcvMg
  #
  # Goals:
  # 1. Do stuff on macOS using nix-darwin and home-manager
  # 2. Do stuff on Linux using home-manager
  description = "Piwonka Flakes";
  inputs = {
    # Where we get most of our software. Giant mono repo with recipes
    # called derivations that say how to build software.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # nixos-22.11

    # Manages configs links things into your home directory
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Controls system level software and settings including fonts
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs@{ nixpkgs, home-manager, darwin, ... }: {
    darwinConfigurations.airtwo = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      pkgs = import nixpkgs { system = "aarch64-darwin"; };
      modules = [
        ./modules/darwin
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.piwonka.imports = [ ./modules/home-manager ];
          };
        }
      ];
    };
  };
}

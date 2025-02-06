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

  outputs = { self, nixpkgs, home-manager, darwin, ... }@inputs:
    {
    darwinConfigurations.mac =
      let
        user = "piwonka";
        system = "aarch64-darwin";

      in darwin.lib.darwinSystem {
        pkgs = import nixpkgs { inherit system; };
        modules = [
          ({ pkgs, ... }: {
            users.users.${user}.home = "/Users/${user}";
          })
          ./modules/darwin
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              # Setting this to false fixed problems with ~/.nix-profile
              useUserPackages = false;
              users.${user}.imports =
                [
                  ./modules/home-manager
                  ./modules/home-manager/mac-home
                ];
            };
          }
        ];
      };

    darwinConfigurations.mac-work =
      let
        user = "piwonka";
        system = "aarch64-darwin";
      in darwin.lib.darwinSystem {
        pkgs = import nixpkgs { inherit system; };
        modules = [
          ({ pkgs, ... }: {
            users.users.${user}.home = "/Users/${user}";
          })
          ./modules/darwin
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              # Setting this to false fixed problems with ~/.nix-profile
              useUserPackages = false;
              users.${user}.imports =
                [
                  ./modules/home-manager
                  ./modules/home-manager/mac-work
                ];
            };
          }
        ];
      };

    # standalone home-manager installation
    homeConfigurations.raspberrypi =
      let
        user = "piwonka";
        system = "aarch64-linux";
      in home-manager.lib.homeManagerConfiguration {
        # modifies pkgs to allow unfree packages
        pkgs = import nixpkgs { inherit system; };
        # makes all inputs available in imported files
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./modules/home-manager
          ./modules/home-manager/linux-home
          ({ ... }: {
            home = {
              username = user;
              homeDirectory = "/home/${user}";
            };
          })
        ];
      };

    # standalone home-manager installation
    homeConfigurations.ec2 =
      let
        user = "ec2-user";
        system = "x86_64-linux";
      in home-manager.lib.homeManagerConfiguration {
        # modifies pkgs to allow unfree packages
        pkgs = import nixpkgs { inherit system; };
        # makes all inputs available in imported files
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./modules/home-manager
          ./modules/home-manager/linux-home
          ({ ... }: {
            home = {
              username = user;
              homeDirectory = "/home/${user}";
            };
          })
        ];
      };

    # standalone home-manager installation
    homeConfigurations.clouddesktop =
      let
        user = "piwonka";
        system = "x86_64-linux";
      in home-manager.lib.homeManagerConfiguration {
        # modifies pkgs to allow unfree packages
        pkgs = import nixpkgs { inherit system; };
        # makes all inputs available in imported files
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./modules/home-manager
          ./modules/home-manager/linux-work
          ({ ... }: {
            home = {
              username = user;
              homeDirectory = "/home/${user}";
            };
          })
        ];
      };

    # standalone home-manager installation
    homeConfigurations.clouddesktop-arm =
      let
        user = "piwonka";
        system = "aarch64-linux";
      in home-manager.lib.homeManagerConfiguration {
        # modifies pkgs to allow unfree packages
        pkgs = import nixpkgs { inherit system; };
        # makes all inputs available in imported files
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./modules/home-manager
          ./modules/home-manager/linux-work
          ({ ... }: {
            home = {
              username = user;
              homeDirectory = "/home/${user}";
            };
          })
        ];
      };
  };
}

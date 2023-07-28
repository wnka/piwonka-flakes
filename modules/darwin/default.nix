{ pkgs, ... }: {
  # here go the darwin preferences and config items
  programs.fish.enable = true;
  environment = {
    shells = with pkgs; [ bash zsh fish ];
    loginShell = pkgs.fish;
    systemPackages = [ pkgs.coreutils pkgs.direnv ];
    systemPath = [ "/opt/homebrew/bin" ];
    pathsToLink = [ "/Applications" ];
  };
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  services.nix-daemon.enable = true;
  system.defaults = {
    finder.AppleShowAllExtensions = true;
    finder._FXShowPosixPathInTitle = true;
    dock.autohide = true;
    NSGlobalDomain.AppleShowAllExtensions = true;
    NSGlobalDomain.InitialKeyRepeat = 14;
    NSGlobalDomain.KeyRepeat = 1;
    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
      Dragging = true;
    };
  };
  # backwards compat; don't change
  system.stateVersion = 4;
  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    global.brewfile = true;
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    casks = [
      "amethyst"
      "authy"
      "bartender"
      "discord"
      "font-blex-mono-nerd-font"
      "font-hack-nerd-font"
      "font-ibm-plex"
      "font-iosevka"
      "font-iosevka-slab"
      "font-jetbrains-mono-nerd-font"
      "font-roboto-mono-nerd-font"
      "handbrake"
      "iina"
      "keybase"
      "keyboardcleantool"
      "kindle"
      "kitty"
      "raycast"
      "rectangle"
      "sonos"
      "steam"
      "transmit"
      "vscodium"
    ];
    taps = [
      "d12frosted/emacs-plus"
    ];
    brews = [
      "emacs-plus@28"
      "terminal-notifier"
    ];
  };
}

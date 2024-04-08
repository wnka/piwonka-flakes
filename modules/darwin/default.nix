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

  # Hack to make pam-reattach work
  environment.etc."pam.d/sudo_local".text = ''
    # Written by nix-darwin
    auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so
    auth       sufficient     pam_tid.so
  '';

  services.nix-daemon.enable = true;
  system.defaults = {
    finder.AppleShowAllExtensions = true;
    finder._FXShowPosixPathInTitle = true;
    dock.autohide = true;
    NSGlobalDomain.AppleShowAllExtensions = true;
    NSGlobalDomain.InitialKeyRepeat = 14;
    NSGlobalDomain.KeyRepeat = 1;
    NSGlobalDomain."com.apple.sound.beep.feedback" = 1;
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
      "1password"
      "arc"
      "authy"
      "bartender"
      "discord"
      "font-blex-mono-nerd-font"
      "font-hack-nerd-font"
      "font-ibm-plex"
      "font-iosevka"
      "font-iosevka-slab"
      "font-jetbrains-mono-nerd-font"
      "font-monaspace"
      "font-recursive-mono-nerd-font"
      "font-roboto-mono-nerd-font"
      "handbrake"
      "iina"
      "keybase"
      "keyboardcleantool"
      "kindle"
      "monitorcontrol"
      "moonlight"
      "raycast"
      "rectangle"
      "sonos"
      "steam"
      "syncthing"
      "transmit"
      "visual-studio-code"
      "wireshark"
    ];
    taps = [
      "d12frosted/emacs-plus"
      "homebrew/cask-fonts"
    ];
    brews = [
      {
        name = "emacs-plus@29";
        args = [
          "with-native-comp"
          "with-nobu417-big-sur-icon"
          "with-xwidgets"
        ];
        link = true;
        start_service = true;
      }
      "gitwatch"
      "hugo"
      "mas"
      "terminal-notifier"
    ];
    masApps = {
      "1Password for Safari" = 1569813296;
      "Cog" = 1630499622;
      "Day One" = 1055511498;
      "Infuse" = 1136220934;
      "Ivory for Mastodon" = 6444602274;
      "PCalc" = 403504866;
      "Pixelmator Pro" = 1289583905;
      "Reeder" = 1529448980;
      "Spark Classic" = 1176895641;
      "Tailscale" = 1475387142;
      "Things 3" = 904280696;
      "TripMode" = 1513400665;
      "Xcode" = 497799835;
    };
  };
}

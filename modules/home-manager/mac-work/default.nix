{ config, lib, pkgs, ... }:

{
  imports = [ ../work-common.nix ];

  home.packages = with pkgs; [
    pam-reattach
  ];
  
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
      fish_add_path /Users/piwonka/.toolbox/bin
      fish_add_path /opt/homebrew/opt/llvm/bin
      fish_add_path /Users/piwonka/.cargo/bin
      fish_add_path /Applications/Obsidian.app/Contents/MacOS
      fish_add_path /Users/piwonka/.local/bin
    '';
    shellAliases = {
      funtime = "bash ~/bin/funtime.sh";
      worktime = "bash ~/bin/worktime.sh";
      nixs = "sudo darwin-rebuild switch --flake ~/code/nix/piwonka-flakes#mac-work";
      # Activate only the home-manager arm (no sudo, no system rebuild). Run `nixs` when you've also changed darwin-level config.
      nixh = "nix build ~/code/nix/piwonka-flakes#darwinConfigurations.mac-work.config.home-manager.users.piwonka.home.activationPackage --out-link /tmp/hm-result && /tmp/hm-result/activate";
      towiki = "pandoc --wrap=none -f org -t xwiki (fzf --preview 'bat --color=always --style=plain {}') | pbcopy";
      tomarkdown = "pandoc --wrap=none -f org -t markdown-smart (fzf --preview 'bat --color=always --style=plain {}') | pbcopy";
      dw = "~/bin/daywon -o ~/Documents/pdp-vault -l -c -t";
      dwl = "~/bin/daywon -l";
      pdd = "et --terminal-path /home/piwonka/.nix-profile/bin/etterminal etr8id -p 2026";
    };
  };
}

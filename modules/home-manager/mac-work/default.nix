{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    pam-reattach
  ];
  
  home.file.".gitconfig".source = ../files/gitconfig;
  home.file.".gitconfig.work".source = ../files/gitconfig-work;

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
      set -x AWS_PROFILE work-personal
    '';
    shellAliases = {
      funtime = "bash ~/bin/funtime.sh";
      worktime = "bash ~/bin/worktime.sh";
      nixs = "sudo darwin-rebuild switch --flake ~/code/nix/piwonka-flakes#mac-work";
      towiki = "pandoc --wrap=none -f org -t xwiki (fzf --preview 'bat --color=always --style=plain {}') | pbcopy";
      tomarkdown = "pandoc --wrap=none -f org -t markdown-smart (fzf --preview 'bat --color=always --style=plain {}') | pbcopy";
      bb = "brazil-build";
      bbr = "brazil-build release";
      dw = "~/bin/daywon -o ~/Documents/pdp-vault -l -a -c -r devdsk-no-vpn -r g4desktop -r g3desktop";
      dwdsk = "~/bin/daywon -r devdsk-no-vpn";
      # Intel DevDesktop
      et-i = "et etdesktop";
      # Arm DevDesktop AL2023
      et-a = "et -p 2023 --terminal-path /home/piwonka/.nix-profile/bin/etterminal etg4desktop";
      # Arm DevDesktop AL2
      et-a2 = "et -p 2024 --terminal-path /home/piwonka/.nix-profile/bin/etterminal etg3desktop";
    };
  };
}

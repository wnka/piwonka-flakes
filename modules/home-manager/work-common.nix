{
  xdg.configFile."git/config".source = ./files/git/gitconfig;
  xdg.configFile."git/config.work".source = ./files/git/gitconfig-work;

  programs.fish = {
    shellInit = ''
      set -x AWS_PROFILE work-personal
    '';
    functions = {
      sn = {
        body = ''slack-mcp -m "$argv"'';
      };
      rsn = {
        body = ''
          set -l last_status $status
          set -l label (test -n "$argv"; and echo "$argv - "(pwd); or pwd)
          if test $last_status -eq 0
              slack-mcp -m "✅ $label"
          else
              slack-mcp -m "❌ $label"
          end
        '';
      };
    };
    shellAliases = {
      bb = "brazil-build";
      bbr = "brazil-build release";
    };
  };
}

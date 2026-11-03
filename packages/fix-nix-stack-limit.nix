{ writeShellApplication, writeText, coreutils }:

let
  stackLimit = writeText "90-nix-stack-limit.conf" ''
    # Managed by piwonka-flakes: nix run .#fix-nix-stack-limit
    # Keep the cloud desktop's 10 MiB soft limit; Nix needs at least 60 MiB hard.
    [Manager]
    DefaultLimitSTACK=10M:64M
  '';
in
writeShellApplication {
  name = "fix-nix-stack-limit";
  runtimeInputs = [ coreutils ];
  text = ''
    if [[ ! -d /run/systemd/system ]]; then
      echo "This setup command requires a Linux host running systemd." >&2
      exit 1
    fi

    if (( EUID != 0 )); then
      exec sudo -- "$0" "$@"
    fi

    install -D -m 0644 ${stackLimit} \
      /etc/systemd/system.conf.d/90-nix-stack-limit.conf
    systemctl daemon-reload

    echo "Installed a 64 MiB hard stack limit (10 MiB soft)."
    echo "Existing services and sessions retain their old limits."
    echo "Reboot when convenient, then check: ulimit -Hs"
  '';
}

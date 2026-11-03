# Piwonka Flakes

A Nix flake configuration for managing development environments across macOS and Linux systems using nix-darwin and home-manager.

## Overview

This flake provides declarative system and user environment configurations for multiple platforms and use cases. It's inspired by [zmre/mac-nix-simple-example](https://github.com/zmre/mac-nix-simple-example) and supports both macOS (via nix-darwin) and Linux (via standalone home-manager).

## Configurations

### Darwin Configurations (macOS)

#### `darwinConfigurations.mac`
- **Platform**: Apple Silicon macOS (aarch64-darwin)
- **User**: piwonka
- **Purpose**: Personal macOS setup
- **Modules**: 
  - `./modules/darwin` - System-level macOS configuration
  - `./modules/home-manager` - Base home-manager configuration
  - `./modules/home-manager/mac-home` - Personal macOS home configuration

#### `darwinConfigurations.mac-work`
- **Platform**: Apple Silicon macOS (aarch64-darwin)
- **User**: piwonka
- **Purpose**: Work macOS setup
- **Modules**:
  - `./modules/darwin` - System-level macOS configuration
  - `./modules/home-manager` - Base home-manager configuration
  - `./modules/home-manager/mac-work` - Work-specific macOS home configuration

### Home Manager Configurations (Linux)

#### `homeConfigurations.raspberrypi`
- **Platform**: ARM64 Linux (aarch64-linux)
- **User**: piwonka
- **Purpose**: Raspberry Pi setup
- **Modules**:
  - `./modules/home-manager` - Base home-manager configuration
  - `./modules/home-manager/linux-home` - Personal Linux home configuration

#### `homeConfigurations.ec2`
- **Platform**: x86_64 Linux
- **User**: ec2-user
- **Purpose**: AWS EC2 instance setup
- **Modules**:
  - `./modules/home-manager` - Base home-manager configuration
  - `./modules/home-manager/linux-home` - Personal Linux home configuration

#### `homeConfigurations.clouddesktop`
- **Platform**: x86_64 Linux
- **User**: piwonka
- **Purpose**: Cloud desktop environment
- **Modules**:
  - `./modules/home-manager` - Base home-manager configuration
  - `./modules/home-manager/linux-work` - Work-specific Linux configuration

#### `homeConfigurations.clouddesktop-arm`
- **Platform**: ARM64 Linux (aarch64-linux)
- **User**: piwonka
- **Purpose**: ARM-based cloud desktop environment
- **Modules**:
  - `./modules/home-manager` - Base home-manager configuration
  - `./modules/home-manager/linux-work` - Work-specific Linux configuration

## Usage

### macOS (Darwin)

Build and activate a Darwin configuration:
```bash
# Personal Mac
nix build .#darwinConfigurations.mac.system
sudo ./result/sw/bin/darwin-rebuild switch --flake .#mac

# Work Mac
nix build .#darwinConfigurations.mac-work.system
sudo ./result/sw/bin/darwin-rebuild switch --flake .#mac-work
```

### Linux (Home Manager)

Build and activate a home-manager configuration:
```bash
# Raspberry Pi
nix build .#homeConfigurations.raspberrypi.activationPackage
./result/activate

# EC2 instance
nix build .#homeConfigurations.ec2.activationPackage
./result/activate

# Cloud desktop (x86_64)
nix build .#homeConfigurations.clouddesktop.activationPackage
./result/activate

# Cloud desktop (ARM64)
nix build .#homeConfigurations.clouddesktop-arm.activationPackage
./result/activate
```

### Linux cloud desktop stack limit

If `nixs` reports `Stack size hard limit is 10485760`, the cloud desktop's
systemd configuration caps the stack at 10 MiB. Nix requests 60 MiB, and an
unprivileged shell cannot raise that inherited hard limit.

Run this once from the flake directory on each affected Linux host:

```bash
nix run .#fix-nix-stack-limit
```

The command uses `sudo` to install
`/etc/systemd/system.conf.d/90-nix-stack-limit.conf` and reload systemd. It keeps
the 10 MiB soft limit and raises the hard limit to 64 MiB, overriding the host's
`50-limits.conf`. This host setup is separate from Home Manager activation
because standalone Home Manager manages user configuration.

Existing services and sessions keep their inherited limits. Reboot when
convenient so SSH, Eternal Terminal, the user service manager, and the Nix daemon
all inherit the new limit. After reconnecting, `ulimit -Hs` should report
`65536`, and `nixs` should no longer produce the warning. The first setup command
may still print the warning because Nix starts before the fix is installed.

To use the higher limit immediately in the current Fish session:

```fish
sudo prlimit --pid $fish_pid --stack=:67108864
```

This raises only that shell's hard limit; it does not update other existing
sessions or services.

### Cloud desktop Rust navigation

The x86 cloud desktop's Helix Rust LSP uses `~/bin/rust-analyzer-fast`, built
from the `fast-workspace-navigation` branch in `~/code/rust-analyzer`. Its
`cargo.workspaceOnly` setting keeps navigation between workspace crates and
standard-library navigation while skipping external dependencies. Diagnostics,
completion, build scripts, and proc macros are disabled for code review;
generated code and usages that require omitted types may not resolve.
Reference searches show a spinner and a "Finding references" status message
while rust-analyzer analyzes callers. The Rust LSP request timeout is two
minutes so Helix keeps waiting for cold searches that exceed its default
20-second limit.

## Module Structure

- `modules/darwin/` - macOS system-level configurations (fonts, system settings, etc.)
- `modules/home-manager/` - Base home-manager configuration shared across all systems
- `modules/home-manager/mac-home/` - Personal macOS-specific home configuration
- `modules/home-manager/mac-work/` - Work macOS-specific home configuration
- `modules/home-manager/linux-home/` - Personal Linux-specific home configuration
- `modules/home-manager/linux-work/` - Work Linux-specific home configuration

## Dependencies

This flake uses the following inputs:
- **nixpkgs**: Main package repository (nixpkgs-unstable)
- **home-manager**: Manages user environment and dotfiles
- **darwin**: Provides macOS system-level configuration capabilities

## Security

This repository uses git-crypt for encrypting sensitive configuration files. Encrypted files are marked in `.gitattributes`.

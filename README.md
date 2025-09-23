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

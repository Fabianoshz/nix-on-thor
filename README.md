# NixOS on AYN Thor

Bootable NixOS Linux distribution for the AYN Thor handheld gaming device (Snapdragon 8 Gen 2 - SM8550).

## About

This project aims to port NixOS to the AYN Thor, enabling a declarative, reproducible Linux environment on ARM64 hardware designed for mobile gaming.

## Hardware

- **Device**: AYN Thor
- **SoC**: Qualcomm Snapdragon 8 Gen 2 (SM8550)
- **Architecture**: ARM64

## Components

- **u-boot**: Custom bootloader for SM8550 (from AYN's fork)
- **Linux kernel**: 6.17.5 with 50+ device-specific patches
- **Firmware**: Proprietary firmware for WiFi, GPU, Audio DSP, Video, USB
- **NixOS**: Minimal system configuration with basic shell

## Building

### Prerequisites

```bash
# Enable flakes if not already enabled
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### Build individual components

```bash
# Build u-boot
nix build .#u-boot

# Build kernel
nix build .#kernel

# Build firmware
nix build .#firmware

# Build full NixOS system
nix build .#nixosConfigurations.ayn-thor.config.system.build.toplevel
```

## Flashing

### U-Boot (temporary test)
```bash
fastboot boot result/bin/u-boot.img
```

### U-Boot (permanent)
```bash
fastboot flash loader result/bin/u-boot.img
```

## Status

Early development - u-boot and kernel build successfully. System configuration ready.


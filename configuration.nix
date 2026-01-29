{ config, pkgs, lib, ... }:

{
  # Use our custom kernel for AYN Thor
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ./kernel/kernel-mainline.nix { });

  # Include AYN Thor firmware
  hardware.firmware = [
    (pkgs.callPackage ./firmware/firmware-ayn-thor.nix { })
  ];

  # Allow unfree firmware
  nixpkgs.config.allowUnfree = true;

  # Bootloader configuration
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # Use gzip for initrd (kernel doesn't support zstd decompression)
  boot.initrd.compressor = "gzip";

  # Capture boot logs to SD card for debugging
  boot.initrd.postDeviceCommands = ''
    mkdir -p /mnt-log
    mount /dev/mmcblk0p1 /mnt-log || true
    dmesg > /mnt-log/boot.log 2>&1
    echo "Initrd stage reached at $(date)" >> /mnt-log/boot.log
    umount /mnt-log || true
  '';

  # Kernel parameters for SM8550
  boot.kernelParams = [
    "console=ttyMSM0,115200"  # Serial console on Qualcomm UART
    "console=tty0"             # Framebuffer console
    "earlycon"                 # Early boot messages
  ];

  # Enable device tree support
  hardware.deviceTree.enable = true;

  # Filesystem configuration
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  # Swap (optional)
  swapDevices = [ ];

  # Networking
  networking.hostName = "ayn-thor";
  networking.networkmanager.enable = true;

  # Enable SSH for remote access
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # Basic system packages
  environment.systemPackages = with pkgs; [
    vim
    htop
    tmux
    git
    wget
    curl
    tree
    file
  ];

  # Create a default user
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "input" ];
    password = "nixos";  # Change this!
  };

  # Allow passwordless sudo for wheel group (development)
  security.sudo.wheelNeedsPassword = false;

  # Enable serial console
  systemd.services."serial-getty@ttyMSM0".enable = true;

  # Graphics/GPU support (Adreno)
  hardware.graphics.enable = true;

  # Sound support
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Power management
  powerManagement.enable = true;

  # Timezone and locale
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  # Minimal X11 setup (optional - for graphical shell)
  services.xserver = {
    enable = false;  # Set to true if you want GUI
    displayManager.lightdm.enable = false;
    desktopManager.xfce.enable = false;
  };

  # System state version
  system.stateVersion = "24.11";
}

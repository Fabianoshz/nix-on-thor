{
  description = "NixOS for AYN Thor (SM8550)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.ayn-thor = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";  # Build host

      modules = [
        ./configuration.nix

        # Cross-compilation setup
        {
          nixpkgs.crossSystem = {
            config = "aarch64-unknown-linux-gnu";
            system = "aarch64-linux";
          };
        }
      ];
    };

    # Expose individual components
    packages.x86_64-linux =
      let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      in {
        kernel = pkgs.pkgsCross.aarch64-multiplatform.callPackage ./kernel/kernel-mainline.nix { };
        u-boot = pkgs.callPackage ./bootloader/u-boot.nix { };
        firmware = pkgs.callPackage ./firmware/firmware-ayn-thor.nix { };
      };
  };
}

{ pkgs, lib, ... }:

let
  # Load all patch files from the patches directory
  patchesDir = ./patches;
  patchFiles = builtins.sort (a: b: a < b) (
    builtins.filter (name: lib.hasSuffix ".patch" name)
      (builtins.attrNames (builtins.readDir patchesDir))
  );

  # Convert patch filenames to patch attribute sets
  # Note: Nix store paths can't contain commas, so we use builtins.path with sanitized names
  aynPatches = map (name:
    let
      sanitizedName = builtins.replaceStrings [","] ["-"] name;
    in {
      name = sanitizedName;
      patch = builtins.path {
        path = patchesDir + "/${name}";
        name = sanitizedName;
      };
    }
  ) patchFiles;

in pkgs.buildLinux {
  version = "6.17.5";
  modDirVersion = "6.17.5";

  src = pkgs.fetchurl {
    url = "mirror://kernel/linux/kernel/v6.x/linux-6.17.5.tar.xz";
    hash = "sha256-wF+vNunCFkvnI89q2oUzeIgE1I+d0v4b4szuNhapK84=";
  };

  kernelPatches = aynPatches;

  configfile = ./kernel-config;

  extraMeta = {
    description = "Mainline Linux kernel (6.17.5) for AYN Thor with device-specific patches";
    platforms = [ "aarch64-linux" ];
    maintainers = [ ];
  };
}

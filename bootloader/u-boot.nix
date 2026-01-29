{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "u-boot-ayn-thor";
  version = "ayn-sm8550";

  src = pkgs.fetchFromGitHub {
    owner = "AYNTechnologies";
    repo = "u-boot";
    rev = "ayn-sm8550";
    hash = "sha256-CNMDSOmMiqWY3o6x9Rxqornb6NIpjiJzfYm8D7MJkqA=";
  };

  nativeBuildInputs = with pkgs; [
    dtc                      # device-tree-compiler
    gnumake
    python3
    python3Packages.pyelftools
    python3Packages.setuptools
    swig
    gzip
    git
    android-tools            # provides mkbootimg
    bison
    flex
    xxd
  ];

  buildInputs = with pkgs; [
    openssl
    gnutls
    pkgsCross.aarch64-multiplatform.stdenv.cc
  ];

  depsBuildBuild = with pkgs; [
    pkgsCross.aarch64-multiplatform.stdenv.cc
  ];

  postPatch = ''
    patchShebangs scripts tools
    # Fix hardcoded /bin/pwd
    substituteInPlace Makefile \
      --replace '/bin/pwd' 'pwd'
    find . -type f -name "*.sh" -exec sed -i 's|/bin/pwd|pwd|g' {} +
    find . -type f -name "Makefile*" -exec sed -i 's|/bin/pwd|pwd|g' {} +
  '';

  makeFlags = [
    "CROSS_COMPILE=aarch64-unknown-linux-gnu-"
    "O=output"
    "-j$NIX_BUILD_CORES"
  ];

  configurePhase = ''
    runHook preConfigure

    # Create ayn.env file for direct kernel boot from SD card
    mkdir -p board/qualcomm
    cat > board/qualcomm/ayn.env << 'EOF'
bootdelay=1
stdin=button_kbd,serial
stdout=vidconsole,serial
stderr=vidconsole,serial
preboot=scsi scan; usb start; mmc list; mmc rescan; mmc list
bootcmd=mmc dev 0 && setenv bootargs 'console=ttyMSM0,115200 console=tty0 earlycon loglevel=8 debug root=/dev/mmcblk0p2 rootwait rw init=/nix/var/nix/profiles/system/init video=efifb fbcon=vc:0-6' && fatload mmc 0:1 0xbca200000 dtbs/qcom/qcs8550-ayn-thor.dtb && fatload mmc 0:1 0xbdec00000 initrd && fatload mmc 0:1 0xbe6c00000 Image && booti 0xbe6c00000 0xbdec00000:0xaeb19f 0xbca200000
EOF

    make CROSS_COMPILE=aarch64-unknown-linux-gnu- O=output qcom_defconfig

    # Enable direct boot and environment file
    cat >> output/.config << 'EOF'
CONFIG_DEFAULT_ENV_FILE="board/qualcomm/ayn.env"
CONFIG_BOOTDELAY=1
CONFIG_CMD_BOOTI=y
CONFIG_AUTOBOOT_PROMPT="test"
EOF

    make CROSS_COMPILE=aarch64-unknown-linux-gnu- O=output olddefconfig
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    make CROSS_COMPILE=aarch64-unknown-linux-gnu- O=output -j$NIX_BUILD_CORES \
      DEVICE_TREE=qcom/qcs8550-ayn-odin2-common
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    # Package the kernel
    gzip output/u-boot-nodtb.bin -c > output/u-boot-nodtb.bin.gz
    cat output/u-boot-nodtb.bin.gz \
      output/dts/upstream/src/arm64/qcom/qcs8550-ayn-odin2-common.dtb \
      > output/kernel-dtb

    # Create boot image
    mkbootimg --kernel_offset '0x00008000' --pagesize '4096' \
      --kernel output/kernel-dtb -o output/u-boot.img --cmdline "nodtbo"

    # Copy outputs
    cp output/u-boot-nodtb.bin $out/bin/
    cp output/kernel-dtb $out/bin/
    cp output/u-boot.img $out/bin/

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Das U-Boot bootloader for AYN Thor (SM8550)";
    homepage = "https://github.com/AYNTechnologies/u-boot";
    license = licenses.gpl2Plus;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    maintainers = [ ];
  };
}

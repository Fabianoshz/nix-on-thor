{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "firmware-ayn-thor";
  version = "2024-12-01";

  src = fetchFromGitHub {
    owner = "ROCKNIX";
    repo = "distribution";
    rev = "next";
    hash = "sha256-maxTwbLymW+AYg2vIXWD4/xOqPIzZb+300K38TLFysE=";
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/firmware

    # Base firmware path in ROCKNIX repo
    FIRMWARE_SRC="projects/ROCKNIX/devices/SM8550/filesystem/usr/lib/kernel-overlays/base/lib/firmware"

    # Install ADSP (Audio DSP) firmware
    mkdir -p $out/lib/firmware/qcom/sm8550/ayn/thor
    cp -v "$FIRMWARE_SRC/qcom/sm8550/ayn/thor/adsp.mbn" $out/lib/firmware/qcom/sm8550/ayn/thor/
    cp -v "$FIRMWARE_SRC/qcom/sm8550/ayn/thor/adsp_dtb.mbn" $out/lib/firmware/qcom/sm8550/ayn/thor/
    cp -v "$FIRMWARE_SRC/qcom/sm8550/ayn/thor/aw883xx_acf.bin" $out/lib/firmware/qcom/sm8550/ayn/thor/
    cp -v "$FIRMWARE_SRC/qcom/sm8550/ayn/thor/"*.jsn $out/lib/firmware/qcom/sm8550/ayn/thor/

    # Install GPU and CDSP firmware
    mkdir -p $out/lib/firmware/qcom/sm8550/ayn
    cp -v "$FIRMWARE_SRC/qcom/sm8550/ayn/a740_zap.mbn" $out/lib/firmware/qcom/sm8550/ayn/
    cp -v "$FIRMWARE_SRC/qcom/sm8550/ayn/cdsp.mbn" $out/lib/firmware/qcom/sm8550/ayn/
    cp -v "$FIRMWARE_SRC/qcom/sm8550/ayn/cdsp_dtb.mbn" $out/lib/firmware/qcom/sm8550/ayn/

    # Install GPU shader firmware
    mkdir -p $out/lib/firmware/qcom
    cp -v "$FIRMWARE_SRC/qcom/a740_sqe.fw" $out/lib/firmware/qcom/
    cp -v "$FIRMWARE_SRC/qcom/gmu_gen70200.bin" $out/lib/firmware/qcom/

    # Install audio topology
    mkdir -p $out/lib/firmware/qcom/sm8550
    cp -v "$FIRMWARE_SRC/qcom/sm8550/SM8550-APS-tplg.bin" $out/lib/firmware/qcom/sm8550/

    # Install VPU (Video Processing Unit)
    mkdir -p $out/lib/firmware/qcom/vpu
    cp -v "$FIRMWARE_SRC/qcom/vpu/vpu30_p4.mbn" $out/lib/firmware/qcom/vpu/

    # Install WiFi 7 firmware (WCN7850)
    mkdir -p $out/lib/firmware/ath12k/WCN7850/hw2.0
    cp -v "$FIRMWARE_SRC/ath12k/WCN7850/hw2.0/amss.bin" $out/lib/firmware/ath12k/WCN7850/hw2.0/
    cp -v "$FIRMWARE_SRC/ath12k/WCN7850/hw2.0/board-2.bin" $out/lib/firmware/ath12k/WCN7850/hw2.0/
    cp -v "$FIRMWARE_SRC/ath12k/WCN7850/hw2.0/m3.bin" $out/lib/firmware/ath12k/WCN7850/hw2.0/
    cp -v "$FIRMWARE_SRC/ath12k/WCN7850/hw2.0/regdb.bin" $out/lib/firmware/ath12k/WCN7850/hw2.0/

    # Install USB controller firmware
    cp -v "$FIRMWARE_SRC/renesas_usb_fw.mem" $out/lib/firmware/

    runHook postInstall
  '';

  meta = {
    description = "Proprietary firmware files for AYN Thor (SM8550) hardware";
    platforms = [ "x86_64-linux" "aarch64-linux" ];  # Firmware is just data files
    license = "unfree";  # Proprietary firmware
  };
}

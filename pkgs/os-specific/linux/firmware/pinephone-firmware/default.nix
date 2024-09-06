{
  lib,
  stdenvNoCC,
  fetchgit,
}:

stdenvNoCC.mkDerivation {
  pname = "pinephone-firmware";
  version = "0-unstable-2021-10-27";

  src = fetchgit {
    url = "https://megous.com/git/linux-firmware";
    rev = "6e8e591e17e207644dfe747e51026967bb1edab5";
    hash = "sha256-TaGwT0XvbxrfqEzUAdg18Yxr32oS+RffN+yzSXebtac=";
  };

  dontBuild = true;

  dontFixup = true;

  installPhase = ''
    mkdir -p "$out/lib/firmware"
    cp -vrf "$src/rtl_bt" $out/lib/firmware/
    cp -vf "$src/anx7688-fw.bin" $out/lib/firmware/
    cp -vf "$src/ov5640_af.bin" $out/lib/firmware/
  '';

  meta = with lib; {
    description = "Firmware files for Pinephone";
    homepage = "https://megous.com/git/linux-firmware";
    license = licenses.unfreeRedistributableFirmware;
    maintainers = with maintainers; [ wegank ];
  };
}

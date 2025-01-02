{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  fetchurl,
  hello,
  buildLinux,
  ...
}@args:

let
  rev = "1c86d6592b2ab309943dbb5d931359a40b5808ec";
  configfile = fetchurl {
    url = "https://raw.githubusercontent.com/NixOS/mobile-nixos/${rev}/devices/pine64-pinephone/kernel/config.aarch64";
    sha256 = "sha256-95rMZaylQzvDTOiX6rqVfF2pPlR/6bEiUQBHqP8JhIo=";
  };
  version = "5.19.8"; # 5.19
  modDirVersion = version; # 5.19.0
in
if !stdenv.hostPlatform.isLinux then
  hello.overrideAttrs {
    meta = {
      broken = true;
      platforms = [ ];
    };
  }
else
  buildLinux (
    args
    // {
      inherit version modDirVersion;
      extraMeta.branch = version;

      src = fetchFromGitHub {
        # https://github.com/megous/linux
        owner = "megous";
        repo = "linux";
        rev = "orange-pi-5.19-20220909-1622";
        postFetch = ''
          cat ${configfile} > $out/arch/arm64/configs/defconfig
        '';
        sha256 = "sha256-cdFXepH+pytywAz6lmT62zkdbGC02BkJt+a/CPyH3ps=";
      };

      kernelPatches = [
        {
          name = "setup-default-on-and-panic-leds";
          patch = fetchpatch {
            url = "https://raw.githubusercontent.com/NixOS/mobile-nixos/${rev}/devices/pine64-pinephone/kernel/0001-dts-pinephone-Setup-default-on-and-panic-LEDs.patch";
            sha256 = "sha256-Gat478Po6DD+fwn79XmxW0thbJdI33lSHQdVkne+6OA=";
          };
        }
        {
          name = "configure-128mib-cma";
          patch = fetchpatch {
            url = "https://github.com/mobile-nixos/linux/commit/372597b5449b7e21ad59dba0842091f4f1ed34b2.patch";
            sha256 = "1lca3fdmx2wglplp47z2d1030bgcidaf1fhbnfvkfwk3fj3grixc";
          };
        }
        {
          name = "drop-modem-power-node";
          patch = fetchpatch {
            url = "https://gitlab.com/postmarketOS/pmaports/-/raw/164e9f010dcf56642d8e6f422a994b927ae23f38/device/main/linux-postmarketos-allwinner/0007-dts-pinephone-drop-modem-power-node.patch";
            sha256 = "nYCoaYj8CuxbgXfy5q43Xb/ebe5DlJ1Px571y1/+lfQ=";
          };
        }
      ];

      structuredExtraConfig = with lib.kernel; {
        #   CC [M]  drivers/video/fbdev/sun5i-eink-neon.o
        # gcc: error: unrecognized command line option '-mfloat-abi=softfp'
        # gcc: error: unrecognized command line option '-mfpu=neon'
        FB_SUN5I_EINK = no;
      };

      extraMeta.broken = !stdenv.hostPlatform.isAarch64;
    }
    // (args.argsOverride or { })
  )

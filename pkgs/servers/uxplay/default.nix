{ lib
, stdenv
, pkg-config
, fetchFromGitHub
, cmake
, wrapGAppsHook
, a52dec
, avahi
, avahi-compat
, openssl
, gst_all_1
, libplist
}:

stdenv.mkDerivation rec {
  pname = "uxplay";
  version = "1.52";

  src = fetchFromGitHub {
    owner = "FDH2";
    repo = "UxPlay";
    rev = "v${version}";
    sha256 = "sha256-2wPUG50fbXLg6w2Rni3NyeiCyUNPcOvxvqopD9QZJaQ=";
  };

  prePatch = lib.optionalString stdenv.isDarwin ''
    sed -i "45,50d;55d;58d;65,71d;75d;79,95d" lib/CMakeLists.txt
  '';

  nativeBuildInputs = [
    cmake
    openssl
    libplist
    pkg-config
    wrapGAppsHook
  ];

  buildInputs = [
    avahi
    avahi-compat
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    (gst_all_1.gst-plugins-ugly.override {
      inherit a52dec;
    })
    gst_all_1.gst-libav
  ];

  meta = with lib; {
    # broken = stdenv.isDarwin;
    homepage = "https://github.com/FDH2/UxPlay";
    description = "AirPlay Unix mirroring server";
    license = licenses.gpl3Plus;
    # maintainers = with maintainers; [ azuwis ];
    platforms = platforms.unix;
  };
}
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
  version = "1.58";

  src = fetchFromGitHub {
    owner = "FDH2";
    repo = "UxPlay";
    rev = "v${version}";
    sha256 = "sha256-KkYIj5W6yMQi8En24Bo77GMK/AOS2qJhadQJYSd7gXs=";
  };

  prePatch = lib.optionalString stdenv.isDarwin ''
    sed -i '55,68d;73d;76,82d;89d;93,113d;117d' lib/CMakeLists.txt
    sed -i '4,10d' renderers/CMakeLists.txt
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
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
  ];

  meta = with lib; {
    homepage = "https://github.com/FDH2/UxPlay";
    description = "AirPlay Unix mirroring server";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ azuwis ];
    platforms = platforms.unix;
  };
}

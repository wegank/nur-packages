{ lib
, stdenv
, fetchFromGitLab
, meson
, ninja
, pkg-config
, glib
, glibmm
, libgpiod
, libgudev
, libusb1
, curl
, eggdbus
, modemmanager
}:

stdenv.mkDerivation rec {
  pname = "eg25-manager";
  version = "0.4.5";

  src = fetchFromGitLab {
    owner = "mobian1";
    repo = pname;
    rev = version;
    hash = "sha256-+kd6mDjdACCd31lm1F2adltCa6oeUSzXOi1MlczRqlQ=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    curl
    eggdbus
    glib
    glibmm
    libgpiod
    libgudev
    libusb1
    modemmanager
  ];

  meta = with lib; {
    description = "Manager daemon for the Quectel EG25 mobile broadband modem";
    homepage = "https://gitlab.com/mobian1/devices/eg25-manager";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ tomfitzhenry ];
    platforms = [ "aarch64-linux" ];
    broken = !(stdenv.isAarch64 && stdenv.isLinux);
  };
}

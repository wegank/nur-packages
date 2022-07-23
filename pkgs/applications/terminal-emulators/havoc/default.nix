{ lib
, stdenv
, fetchFromGitHub
, libxkbcommon
, pkg-config
, wayland
, wayland-protocols
, epoll-shim
}:

stdenv.mkDerivation rec {
  pname = "havoc";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "ii8";
    repo = pname;
    rev = version;
    hash = "sha256-zNKDQqkDeNj5fB5EdMVfAs2H4uBgLh6Fp3uSjiJ1VhQ=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libxkbcommon
    wayland
    wayland-protocols
  ] ++ lib.optionals (!stdenv.isLinux) [
    epoll-shim
  ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace "CFLAGS ?= " "CFLAGS ?= -I${epoll-shim}/include/libepoll-shim " \
      --replace "LIBS=-lrt " "LIBS=-lepoll-shim "
    substituteInPlace main.c \
      --replace "pty.h" "util.h" \
      --replace "&wl_seat_interface, 5" "&wl_seat_interface, 2"
    sed -i "32istruct itimerspec { struct timespec it_interval; struct timespec it_value; };" main.c
  '';

  dontConfigure = true;

  installFlags = [ "PREFIX=$$out" ];

  postInstall = ''
    install -D -m 644 havoc.cfg -t $out/etc/${pname}/
    install -D -m 644 README.md -t $out/share/doc/${pname}-${version}/
  '';

  meta = with lib; {
    homepage = "https://github.com/ii8/havoc";
    description = "A minimal terminal emulator for Wayland";
    license = with licenses; [ mit publicDomain ];
    platforms = with platforms; unix;
    maintainers = with maintainers; [ AndersonTorres ];
  };
}

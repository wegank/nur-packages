{ lib
, stdenv
, fetchFromGitHub
, cmake
, writeText
, compatItimerspec ? false
}:

stdenv.mkDerivation rec {
  pname = "epoll-shim";
  version = "0.0.20220726";

  src = fetchFromGitHub {
    owner = "jiixyj";
    repo = pname;
    rev = "09a01c242336103427f06e458f248cfac4ccbfab";
    sha256 = "sha256-sElMJcrKnMZhV5GtDsRRYVRd955LuPdev3JQiNptLYc=";
  };

  patches = [
    ./add-darwin-support.patch
  ];

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=${lib.boolToString doCheck}"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  postInstall = lib.optionalString compatItimerspec ''
    mkdir $out/include/libepoll-shim-compat
    cp $src/src/compat_*.h $out/include/libepoll-shim-compat/
  '';

  setupHook =
    if compatItimerspec then
      (writeText "setup-hook" ''
        export NIX_CFLAGS_COMPILE+=" -D COMPAT_ENABLE_ITIMERSPEC -include libepoll-shim-compat/compat_itimerspec.h"
      '')
    else null;

  doCheck = stdenv.isAarch64;

  meta = with lib; {
    description = "Small epoll implementation using kqueue";
    homepage = "https://github.com/jiixyj/epoll-shim";
    license = licenses.mit;
    platforms = platforms.unix;
    broken = stdenv.isLinux;
    maintainers = with maintainers; [ wegank ];
  };
}

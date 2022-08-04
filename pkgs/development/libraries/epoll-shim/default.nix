{ lib
, stdenv
, fetchFromGitHub
, cmake
, writeText
, itimerspecHook ? false
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

  postPatch = ''
    sed -i '1s/hidden/default/;2s/1/0/' src/CMakeLists.txt
  '';

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=${lib.boolToString doCheck}"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  postInstall = lib.optionalString itimerspecHook ''
    cp $src/src/compat_*.h $out/include/
  '';

  setupHook =
    if itimerspecHook then
      (writeText "setup-hook" ''
        export NIX_CFLAGS_COMPILE+=" -I$1/include/libepoll-shim"
        export NIX_CFLAGS_COMPILE+=" -D COMPAT_ENABLE_ITIMERSPEC -include compat_itimerspec.h"
        export NIX_LDFLAGS+=" -L$1/lib -lepoll-shim"
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

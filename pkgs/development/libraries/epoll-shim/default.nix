{ lib
, stdenv
, fetchFromGitHub
, cmake
, writeText
, itimerspecHook ? false
, atomicCloseOnExecHook ? false
}:

let
  hook = itimerspecHook || atomicCloseOnExecHook;
in
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

  postPatch = lib.optionalString hook ''
    sed -i '1s/hidden/default/;2s/1/0/' src/CMakeLists.txt
  '' + lib.optionalString atomicCloseOnExecHook (
    builtins.concatStringsSep "\n" (
      builtins.map
        (feature: "sed -i '118i''$<BUILD_INTERFACE:compat_enable_${feature}>' src/CMakeLists.txt")
        [ "socket" "socketpair" "pipe2" ]
    )
  );

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=${lib.boolToString doCheck}"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  postInstall = lib.optionalString hook ''
    cp $src/src/compat_*.h $out/include/
  '';

  setupHook =
    if !hook then null else
    (writeText "setup-hook" (''
      export NIX_CFLAGS_COMPILE+=" -I$1/include/libepoll-shim"
      export NIX_LDFLAGS+=" -L$1/lib -lepoll-shim"
    '' + lib.optionalString itimerspecHook ''
      export NIX_CFLAGS_COMPILE+=" -D COMPAT_ENABLE_ITIMERSPEC -include compat_itimerspec.h"
    '' + lib.optionalString atomicCloseOnExecHook ''
      export NIX_CFLAGS_COMPILE+=" -D O_CLOEXEC=0x1000000"
      export NIX_CFLAGS_COMPILE+=" -D COMPAT_ENABLE_SOCKET -include compat_socket.h"
      export NIX_CFLAGS_COMPILE+=" -D COMPAT_ENABLE_SOCKETPAIR -include compat_socketpair.h"
      export NIX_CFLAGS_COMPILE+=" -D COMPAT_ENABLE_PIPE2 -include compat_pipe2.h"
    ''));

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

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
  atomicFeatures = [ "socket" "socketpair" "pipe2" ];
in
stdenv.mkDerivation rec {
  pname = "epoll-shim";
  version = "0.0.20220802";

  src = fetchFromGitHub {
    owner = "jiixyj";
    repo = pname;
    rev = "22bbd01de491d87cdf6b56fa1cea5bdaca68ea4d";
    sha256 = "sha256-YqnRUZDkTAXoDHy/tm4CX827YqCHrMJBFIS0Dn3x7Uo=";
  };

  patches = [
    ./add-darwin-support.patch
  ];

  postPatch = lib.optionalString hook ''
    sed -i '1s/hidden/default/;2s/1/0/' src/CMakeLists.txt
  '' + lib.optionalString atomicCloseOnExecHook (lib.concatMapStrings
    (feature: ''
      sed -i '118i''$<BUILD_INTERFACE:compat_enable_${feature}>' src/CMakeLists.txt
    '')
    atomicFeatures
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
    let
      enableFeature = feature: ''
        export NIX_CFLAGS_COMPILE+=" -D COMPAT_ENABLE_${lib.toUpper feature} -include compat_${feature}.h"
      '';
    in
    (writeText "setup-hook" (''
      export NIX_CFLAGS_COMPILE+=" -I$1/include/libepoll-shim"
      export NIX_LDFLAGS+=" -L$1/lib -lepoll-shim"
    ''
    + lib.optionalString itimerspecHook (enableFeature "itimerspec")
    + lib.optionalString atomicCloseOnExecHook (''
      export NIX_CFLAGS_COMPILE+=" -D O_CLOEXEC=0x1000000"
    '' + lib.concatMapStrings enableFeature atomicFeatures
    )));

  doCheck = false;

  meta = with lib; {
    description = "Small epoll implementation using kqueue";
    homepage = "https://github.com/jiixyj/epoll-shim";
    license = licenses.mit;
    platforms = platforms.unix;
    broken = stdenv.isLinux;
    maintainers = with maintainers; [ wegank ];
  };
}

{ lib
, stdenv
, fetchFromGitHub
, cmake
}:

stdenv.mkDerivation rec {
  pname = "epoll-shim";
  version = "0.0.20220711";

  src = fetchFromGitHub {
    owner = "jiixyj";
    repo = pname;
    rev = "605be8c2e14b21cd73a714fde93ed5f8c08a7a01";
    sha256 = "sha256-jE3bRz8FhIEp/8sKPkHmvvGD7M1n82zbs9xie2QmE+8=";
  };

  prePatch = lib.optionalString (!stdenv.isx86_64) ''
    substituteInPlace test/epoll-test.c \
      --replace "ATF_REQUIRE(sizeof(event) == 12);" ""
  '' + lib.optionalString stdenv.isDarwin ''
    substituteInPlace CMakeLists.txt \
      --replace "libdata" "lib"
    substituteInPlace epoll-shim.pc.cmakein \
      --replace "\''${exec_prefix}/" "" \
      --replace "\''${prefix}/" ""
    substituteInPlace epoll-shim-interpose.pc.cmakein \
      --replace "\''${exec_prefix}/" "" \
      --replace "\''${prefix}/" ""
  '';

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=true"
    "-DCMAKE_SKIP_BUILD_RPATH=OFF"
  ];

  doCheck = true;

  meta = with lib; {
    description = "Small epoll implementation using kqueue";
    homepage = "https://github.com/jiixyj/epoll-shim";
    license = licenses.mit;
    platforms = platforms.unix;
    broken = stdenv.isLinux;
    # maintainers = with maintainers; [ wegank ];
  };
}

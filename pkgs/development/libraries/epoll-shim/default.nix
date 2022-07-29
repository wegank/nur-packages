{ lib
, stdenv
, fetchFromGitHub
, cmake
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

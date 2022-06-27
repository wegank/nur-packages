{ cmake
, fetchurl
, gmp
, lib
, pkgs ? import <nixpkgs> { }
, stdenv
, unzip
}:

stdenv.mkDerivation rec {
  pname = "pagsuite";
  version = "1.80";

  src = fetchurl {
    url = "https://gitlab.com/kumm/pagsuite/-/raw/master/releases/pagsuite_1_80.zip";
    sha256 = "sha256-TYd+dleVPWEWU9Cb3XExd7ixJZyiUAp9QLtorYJSIbQ=";
  };

  nativeBuildInputs = [
    cmake
    unzip
  ];

  buildInputs = [
    gmp
    (pkgs.callPackage ../scalp { })
  ];

  enableParallelBuilding = false;

  unpackPhase = ''
    unzip -qq $src
    mv pagsuite_1_80/* .
  '';

  meta = with lib; {
    description = "Optimization tools for the (P)MCM problem";
    homepage = "https://gitlab.com/kumm/pagsuite";
    platforms = platforms.unix;
    # maintainers = with maintainers; [ wegank ];
  };
}

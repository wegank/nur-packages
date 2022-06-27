{ cmake
, fetchzip
, gmp
, lib
, pkgs ? import <nixpkgs> { }
, stdenv
, unzip
}:

stdenv.mkDerivation rec {
  pname = "pagsuite";
  version = "1.80";

  src = fetchzip {
    url = "https://gitlab.com/kumm/pagsuite/-/raw/master/releases/pagsuite_1_80.zip";
    sha256 = "sha256-j6eljvRLKc9YGt/uXP0P08HA5MmEowRm2q0I776Dtls=";
    postFetch = ''
      mkdir $out
      ${unzip}/bin/unzip -qq $downloadedFile
      mv pagsuite_1_80/* $out
    '';
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    gmp
    (pkgs.callPackage ../../../../development/libraries/scalp { })
  ];

  enableParallelBuilding = false;

  meta = with lib; {
    description = "Optimization tools for the (P)MCM problem";
    homepage = "https://gitlab.com/kumm/pagsuite";
    platforms = platforms.unix;
    # maintainers = with maintainers; [ wegank ];
  };
}

{ cmake
, fetchFromGitLab
, gmp
, lib
, pkgs ? import <nixpkgs> { }
, stdenv
}:

stdenv.mkDerivation rec {
  pname = "pagsuite";
  version = "1.80-git";

  src = fetchFromGitLab {
    owner = "kumm";
    repo = pname;
    rev = "fe65b8e4ba9eb29fdf18c28b0889980b5bcb866f";
    sha256 = "sha256-gH266J3+sn5Nph8ofh6RSgg+yNyDWa7xU07ReWKwiSM=";
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
{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  flint,
  gmp,
  jemalloc,
  mpi,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "firefly";
  version = "2.0.3-unstable-2025-11-04";

  src = fetchFromGitLab {
    owner = "firefly-library";
    repo = "firefly";
    rev = "72e9e3cd1b05e2ba56edd7dbe0725251df8cb256";
    hash = "sha256-S63L7gKJkKDoSsDpiEcDJS3Tk+GGx3TCdM8y/xrdeNc=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    flint
    gmp
    jemalloc
    mpi
    zlib
  ];

  cmakeFlags = [
    "-DWITH_FLINT=true"
    "-DWITH_JEMALLOC=true"
    "-DWITH_MPI=true"
  ];

  meta = {
    description = "Reconstruction library for rational functions written in C++";
    homepage = "https://gitlab.com/firefly-library/firefly";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ wegank ];
    platforms = lib.platforms.unix;
  };
})

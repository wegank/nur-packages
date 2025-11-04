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
  version = "2.0.3-unstable-2025-07-21";

  src = fetchFromGitLab {
    owner = "firefly-library";
    repo = "firefly";
    rev = "805b86358986cd162cb8a7463b7d185c7797bf3e";
    hash = "sha256-PQ8qJ/x9nccNnyBcWfR8h+kgUwEnnH/xsITQmF9vpLs=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "cmake_minimum_required(VERSION 3.1)" "cmake_minimum_required(VERSION 3.10)"
  '';

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

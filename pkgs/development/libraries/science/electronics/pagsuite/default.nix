{ lib
, stdenv
, fetchurl
, cmake
, makeWrapper
, unzip
, gmp
, scalp
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
    makeWrapper
    unzip
  ];

  buildInputs = [
    gmp
    scalp
  ];

  enableParallelBuilding = false;

  unpackPhase = ''
    unzip -qq $src
    mv pagsuite_1_80/* .
  '';

  postFixup = ''
    wrapProgram $out/bin/omcm \
      --prefix DYLD_LIBRARY_PATH : ${lib.makeLibraryPath ([ scalp ])}
  '';

  meta = with lib; {
    description = "Optimization tools for the (P)MCM problem";
    homepage = "https://gitlab.com/kumm/pagsuite";
    platforms = platforms.unix;
    maintainers = with maintainers; [ wegank ];
  };
}

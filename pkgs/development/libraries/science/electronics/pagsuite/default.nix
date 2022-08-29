{ lib
, stdenv
, fetchzip
, cmake
, gmp
, scalp
}:

stdenv.mkDerivation rec {
  pname = "pagsuite";
  version = "1.80";

  src = fetchzip {
    url = "https://gitlab.com/kumm/${pname}/-/raw/master/releases/${pname}_${builtins.replaceStrings ["."] ["_"] version}.zip";
    stripRoot = false;
    postFetch = ''mv $out/${pname}*/* $out'';
    sha256 = "sha256-JuRuDPhKKBGz8jUBkZcZW5s2berOewjsPNR/n7kuofY=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    gmp
    scalp
  ];

  enableParallelBuilding = false;

  meta = with lib; {
    description = "Optimization tools for the (P)MCM problem";
    homepage = "https://gitlab.com/kumm/pagsuite";
    platforms = platforms.unix;
    maintainers = with maintainers; [ wegank ];
  };
}

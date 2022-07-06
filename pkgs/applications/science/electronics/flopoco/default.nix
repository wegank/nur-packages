{ bison
, boost
, cmake
, fetchpatch
, fetchurl
, flex
, gmp
, installShellFiles
, lib
, libxml2
, mpfi
, mpfr
, pkgs ? import <nixpkgs> { }
, sollya
, stdenv
}:

stdenv.mkDerivation rec {
  pname = "flopoco";
  version = "4.1.2";

  src = fetchurl {
    url = "https://perso.citi-lab.fr/fdedinec/recherche/OldWarez/FloPoCo/flopoco-4.1.2.tgz";
    sha256 = "sha256-MUm5WtyzouUe2TWTIjCU1mNJU8ifPwUfqMZoe4yNNmA=";
  };

  patches = [
    (fetchpatch {
      name = "fix-clang-error-sin-cos.patch";
      url = "https://gitlab.com/flopoco/flopoco/-/commit/de3aa60ad19333952c176c2a2e51f12653ca736b.patch";
      postFetch = ''
        substituteInPlace $out --replace 'FixSinCosCORDIC.hpp' 'CordicSinCos.hpp'
      '';
      sha256 = "sha256-BlamA/MZuuqqvGYto+jPeQPop6gwva0y394Odw8pdwg=";
    })
    (fetchpatch {
      name = "fix-clang-error-atan2.patch";
      url = "https://gitlab.com/flopoco/flopoco/-/commit/a3ffe2436c1b59ee0809b3772b74f2d43c6edb99.patch";
      sha256 = "sha256-dSYcufLHDL0p1V1ghmy6X6xse5f6mjUqckaVqLZnTaA=";
    })
  ];

  nativeBuildInputs = [
    cmake
    installShellFiles
  ];

  buildInputs = [
    bison
    boost
    flex
    gmp
    libxml2
    mpfi
    mpfr
    (pkgs.callPackage ../../../../development/libraries/science/electronics/pagsuite { })
    (pkgs.callPackage ../../../../development/libraries/science/electronics/scalp { })
    sollya
    (pkgs.callPackage ../../../../development/libraries/science/electronics/wcpg { })
  ];

  installPhase = ''
    ./${pname} BuildAutocomplete
    install -Dm755 ${pname} $out/bin/${pname}
    cp bin* fp* ieee* longacc* $out/bin/
    install -Dm644 libFloPoCoLib.a $out/lib/libFloPoCoLib.a
    installShellCompletion --bash ${pname}_autocomplete
  '';

  meta = with lib; {
    description = "The FloPoCo arithmetic core generator";
    homepage = "http://flopoco.org";
    license = licenses.agpl3Plus;
    platforms = platforms.unix;
    # maintainers = with maintainers; [ wegank ];
  };
}

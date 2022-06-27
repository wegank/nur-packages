{ bison
, boost
, cmake
, fetchFromGitLab
, flex
, gmp
, installShellFiles
, lib
, libxml2
, mpfi
, mpfr
, pkgs ? import <nixpkgs> { }
, stdenv
}:

stdenv.mkDerivation rec {
  pname = "flopoco";
  version = "5.0.git";

  src = fetchFromGitLab {
    owner = pname;
    repo = pname;
    rev = "575e634cf8e85d6714e3f8b49638531530107539";
    sha256 = "sha256-wOFEKVRGFOyBGh5IL8X2gbLu/Orabvyv5nqgQhSrmKU=";
  };

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
    (pkgs.callPackage ../pagsuite { })
    (pkgs.callPackage ../../../../development/libraries/scalp { })
    (pkgs.callPackage ../../../../development/interpreters/sollya { })
    (pkgs.callPackage ../../../../development/libraries/wcpg { })
  ];

  installPhase = ''
    ./${pname} BuildAutocomplete
    install -Dm755 ${pname} $out/bin/${pname}
    cp bin2* fp* ieee* longacc* $out/bin/
    install -Dm644 libFloPoCo.a $out/lib/libFloPoCo.a
    installShellCompletion --bash ${pname}_autocomplete
  '';

  meta = with lib; {
    description = "The FloPoCo arithmetic core generator";
    homepage = "http://flopoco.org";
    platforms = platforms.unix;
    # maintainers = with maintainers; [ wegank ];
  };
}

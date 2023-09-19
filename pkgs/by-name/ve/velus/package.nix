{ lib
, stdenv
, fetchFromGitHub
, coqPackages_8_15
, makeWrapper
, ncurses
, ocamlPackages
}:

let
  # https://compcert.org/man/manual002.html
  targets = {
    x86_64-linux = "x86_64-linux";
    aarch64-linux = "aarch64-linux";
    x86_64-darwin = "x86_64-macos";
    aarch64-darwin = "aarch64-macos";
  };
  target = targets.${stdenv.hostPlatform.system}
    or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "velus";
  version = "unstable-2023-06-13";

  src = fetchFromGitHub {
    owner = "INRIA";
    repo = "velus";
    rev = "f2a941fd02403da05ed5bed136a340bb73c6b025";
    fetchSubmodules = true;
    hash = "sha256-Nlwbv99E9lnOp+gYaHespRBuns63nQ6FpBVSOWDxJpU=";
  };

  postPatch = ''
    mkdir -p $out/share/velus
    mv * $out/share/velus
    cd $out/share/velus
  '';

  nativeBuildInputs = [
    coqPackages_8_15.coq
    makeWrapper
    ncurses
    ocamlPackages.findlib
    ocamlPackages.menhir
    ocamlPackages.ocaml
    ocamlPackages.ocamlbuild
  ];

  buildInputs = [
    ocamlPackages.menhirLib
  ];

  prefixKey = "-prefix ";

  configureFlags = [ target ];

  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall

    makeWrapper $out/share/velus/velus $out/bin/velus

    runHook postInstall
  '';

  meta = with lib; {
    description = "A Lustre compiler in Coq";
    homepage = "https://velus.inria.fr";
    license = licenses.unfree;
    maintainers = with maintainers; [ wegank ];
    platforms = platforms.all;
  };
}

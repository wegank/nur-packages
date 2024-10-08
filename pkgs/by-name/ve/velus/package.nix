{
  lib,
  stdenv,
  fetchFromGitHub,
  coqPackages_8_15,
  ncurses,
  ocamlPackages,
}:

let
  # https://compcert.org/man/manual002.html
  targets = {
    x86_64-linux = "x86_64-linux";
    aarch64-linux = "aarch64-linux";
    x86_64-darwin = "x86_64-macos";
    aarch64-darwin = "aarch64-macos";
  };
  target =
    targets.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "velus";
  version = "3.0.0-unstable-2023-06-13";

  outputs = [
    "out"
    "examples"
  ];

  src = fetchFromGitHub {
    owner = "INRIA";
    repo = "velus";
    rev = "f2a941fd02403da05ed5bed136a340bb73c6b025";
    fetchSubmodules = true;
    hash = "sha256-Nlwbv99E9lnOp+gYaHespRBuns63nQ6FpBVSOWDxJpU=";
  };

  nativeBuildInputs = [
    coqPackages_8_15.coq
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

    mkdir -p $out/{bin,share/velus}
    cp _build/src/{velusmain.native,compcert.ini} $out/share/velus
    ln -s $out/share/velus/velusmain.native $out/bin/velus

    cp -R examples $examples

    runHook postInstall
  '';

  meta = with lib; {
    description = "A Lustre compiler in Coq";
    homepage = "https://velus.inria.fr";
    license = licenses.unfree;
    maintainers = with maintainers; [ wegank ];
    platforms = builtins.attrNames targets;
  };
}

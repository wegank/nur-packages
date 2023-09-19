{ lib
, stdenv
, fetchFromGitHub
, coqPackages_8_15
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

  nativeBuildInputs = [
    coqPackages_8_15.compcert
    coqPackages_8_15.coq
    ncurses
    ocamlPackages.findlib
    ocamlPackages.menhir
    ocamlPackages.ocaml
  ];

  buildInputs = [
    ocamlPackages.menhirLib
  ];

  prefixKey = "-prefix ";

  configureFlags = [ target ];

  # remove vendored compcert
  postPatch = ''
    sed -i "/compcert\.ini driver\/Version\.ml proof/d" Makefile
  '';

  preBuild = ''
    cp ${coqPackages_8_15.compcert}/share/compcert.ini CompCert/compcert.ini
    cp -R ${coqPackages_8_15.compcert.lib}/lib/coq/${coqPackages_8_15.coq.coq-version}/user-contrib/compcert/* CompCert
  '';

  meta = with lib; {
    description = "A Lustre compiler in Coq";
    homepage = "https://velus.inria.fr";
    license = licenses.unfree;
    maintainers = with maintainers; [ wegank ];
    platforms = platforms.all;
  };
}

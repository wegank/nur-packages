{ lib
, stdenv
, fetchFromGitLab
, makeWrapper
, ocamlPackages
, ocaml
, runtimeShell
}:

with ocamlPackages;

lib.throwIfNot (lib.versionAtLeast ocaml.version "4.03.0")
  "heptagon is not available for OCaml ${ocaml.version}"

stdenv.mkDerivation rec {
  pname = "heptagon";
  version = "1.05.00";

  src = fetchFromGitLab {
    domain = "gitlab.inria.fr";
    owner = "synchrone";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-b4O48MQT3Neh8a1Z5wRgS701w6XrwpsbSMprlqTT+CE=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    ocaml
    findlib
    menhir
    menhirLib
    camlp4
    ocamlbuild
  ];

  propagatedBuildInputs = [
    lablgtk
    ocamlgraph
  ];

  postFixup = ''
    wrapProgram $out/bin/hepts \
      --prefix CAML_LD_LIBRARY_PATH : "${lablgtk}/lib/ocaml/${ocaml.version}/site-lib/lablgtk2"
  '';

  meta = with lib; {
    description = "Compiler for the Heptagon/BZR synchronous programming language";
    homepage = "https://gitlab.inria.fr/synchrone/heptagon";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ wegank ];
  };
}

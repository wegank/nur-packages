{ lib
, stdenv
, fetchFromGitLab
, ocamlPackages
, ocaml

, lutils
, rdbg
}:

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

  buildInputs = with ocamlPackages; [
    ocaml
    findlib
    menhir
    menhirLib
    camlp4
    ocamlbuild
  ];

  propagatedBuildInputs = with ocamlPackages; [
    lablgtk
    ocamlgraph
  ];

  meta = with lib; {
    description = "A synchronous dataflow language whose syntax and semantics is inspired from Lustre";
    homepage = "https://gitlab.inria.fr/synchrone/heptagon";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ wegank ];
    mainProgram = "heptc";
  };
}

{ lib, buildDunePackage, fetchFromGitHub, stdlib-shims }:

buildDunePackage rec {
  pname = "bdd";
  version = "unstable-2022-07-14";

  minimalOCamlVersion = "4.00.0";

  src = fetchFromGitHub {
    owner = "backtracking";
    repo = "ocaml-bdd";
    rev = "6d1b1d3c24e5784b87e599a00230ce652acb2dcc";
    sha256 = "sha256-3mJZlAFQsI7AgrNQOe6N94CDfX5gXYqQBooV0jcoYEA=";
  };

  propagatedBuildInputs = [ stdlib-shims ];

  meta = with lib; {
    homepage = "https://github.com/backtracking/ocaml-bdd";
    description = "Quick implementation of a Binary Decision Diagrams (BDD) library for OCaml";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ wegank ];
  };
}
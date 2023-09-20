{ lib
, fetchFromGitHub
, ocamlPackages
}:

ocamlPackages.buildDunePackage {
  pname = "zelus";
  version = "2.2-unstable-2023-06-16";

  src = fetchFromGitHub {
    owner = "INRIA";
    repo = "zelus";
    rev = "165d1ebb1f40f1bcdcb0484218dcc46fccc6e0fc";
    hash = "sha256-Y0YosTtAiH+/6hf8Q4jzOHSrXSOh44ODdVQElYAuyGU=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocamlPackages.menhir
  ];

  buildInputs = [
    ocamlPackages.menhirLib
  ];

  meta = with lib; {
    description = "A synchronous language with ODEs";
    homepage = "https://zelus.di.ens.fr";
    license = licenses.unfree;
    mainProgram = "zeluc";
    maintainers = with maintainers; [ wegank ];
  };
}

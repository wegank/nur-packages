{
  lib,
  ocamlPackages,
  fetchFromGitHub,
  cf,
}:

ocamlPackages.buildDunePackage rec {
  pname = "fsevents";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "mirage";
    repo = "ocaml-fsevents";
    tag = version;
    hash = "sha256-RxgJ8+IopqoOzaGHU1wBfhaqbPwvtQSC8FvGw15uO7I=";
  };

  propagatedBuildInputs = with ocamlPackages; [
    cf
    ctypes
  ];

  meta = {
    description = "OCaml bindings to macOS FSEvents";
    homepage = "https://github.com/mirage/ocaml-fsevents";
    changelog = "https://github.com/mirage/ocaml-fsevents/blob/${src.tag}/CHANGES.md";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ wegank ];
    mainProgram = "ocaml-fsevents";
    platforms = lib.platforms.all;
  };
}

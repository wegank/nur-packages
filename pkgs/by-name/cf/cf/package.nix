{
  lib,
  ocamlPackages,
  fetchFromGitHub,
}:

ocamlPackages.buildDunePackage rec {
  pname = "cf";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "mirage";
    repo = "ocaml-cf";
    tag = version;
    hash = "sha256-l3jbG0Z3JzfsTjd0rjZKcAyP5o+1s8B57cqdqKseRS4=";
  };

  propagatedBuildInputs = with ocamlPackages; [
    ctypes
    ctypes-foreign
  ];

  meta = {
    description = "OCaml bindings to macOS CoreFoundation";
    homepage = "https://github.com/mirage/ocaml-cf";
    changelog = "https://github.com/mirage/ocaml-cf/blob/${src.tag}/CHANGES.md";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ wegank ];
    mainProgram = "ocaml-cf";
    platforms = lib.platforms.all;
  };
}

{
  ocamlPackages,
  cf,
}:

ocamlPackages.buildDunePackage {
  pname = "cf-lwt";

  inherit (cf) version src;

  propagatedBuildInputs = with ocamlPackages; [
    cf
    lwt
  ];

  meta = cf.meta // {
    description = "Lwt interface to macOS CoreFoundation";
  };
}

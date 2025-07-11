{
  ocamlPackages,
  fsevents,
  cf-lwt,
}:

ocamlPackages.buildDunePackage {
  pname = "fsevents-lwt";

  inherit (fsevents) version src;

  propagatedBuildInputs = with ocamlPackages; [
    fsevents
    cf-lwt
    cmdliner
    lwt
  ];

  meta = fsevents.meta // {
    description = "Lwt interface to macOS FSEvents";
  };
}

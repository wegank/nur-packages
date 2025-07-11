{
  lib,
  ocamlPackages,
  fetchFromGitHub,
  versionCheckHook,
  nix-update-script,
  cf-lwt,
  fsevents-lwt,
  stdenv,
}:

ocamlPackages.buildDunePackage rec {
  pname = "slipshow";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "panglesd";
    repo = "slipshow";
    tag = "v${version}";
    hash = "sha256-muH6WsZH+BKn+wKcgs3Q2agyAVZgF5xDZg3XAsqNXcw=";
  };

  postPatch = ''
    substituteInPlace ./src/cli/main.ml \
      --replace-fail '%%VERSION%%' '${version}'
  '';

  nativeBuildInputs = with ocamlPackages; [
    js_of_ocaml
  ];

  buildInputs =
    with ocamlPackages;
    [
      astring
      base64
      bos
      cf-lwt
      cmdliner
      dream
      fmt
      fsevents-lwt
      fpath
      js_of_ocaml-lwt
      logs
      lwt
      magic-mime
      ppx_blob
      ppx_sexp_value
      sexplib
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      inotify
    ];

  doCheck = true;

  nativeCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  doInstallCheck = false; # /bin/sh: uname: not found

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Engine for displaying slips, the next-gen version of slides";
    homepage = "https://slipshow.readthedocs.io/en/latest/index.html";
    license = lib.licenses.gpl3Only;
    downloadPage = "https://github.com/panglesd/slipshow";
    maintainers = [ lib.maintainers.ethancedwards8 ];
    teams = [ lib.teams.ngi ];
    mainProgram = "slipshow";
  };
}

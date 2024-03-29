{
  lib,
  stdenv,
  fetchFromGitLab,
  rustPlatform,
  cargo,
  godot_4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "liquidwar7";
  version = "0-unstable-2024-03-16";

  src = fetchFromGitLab {
    owner = "ufoot";
    repo = "liquidwar7";
    rev = "6a77eeec232408753880de91a01e58c86c2482a8";
    hash = "sha256-ko1CY6qhwESv4YOC2z/xQwhOGd5hHRcODYt1LRwAYqs=";
  };

  postPatch = ''
    substituteInPlace grcc.mk \
      --replace-fail "\$(wildcard /opt/godot-rust-cross-compiler.txt)" "yes" \
      --replace-fail "godot_headless" "godot4 --headless" \
      --replace-fail "--export" "--export-release"
    cp ${./export_presets.cfg} godot/export_presets.cfg
  '';

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "godot-0.1.0" = "sha256-MxpLS2Epak9pUq49J0ADzLkSoSPiBqgXQq1sIC2yMm8=";
      "godot4-prebuilt-0.0.0" = "sha256-9tRAH2KhxQqc35uX2yxTXEW/7DvfXtkuU2PBkvS3ppo=";
    };
  };

  cargoRoot = "rust";

  nativeBuildInputs = [
    cargo
    godot_4
    rustPlatform.cargoSetupHook
  ];

  preBuild = ''
    export HOME=$(mktemp -d)
  '';

  makeFlags = [
    "all"
    "linux"
  ];

  meta = {
    description = "A distributed wargame";
    homepage = "https://gitlab.com/ufoot/liquidwar7";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ wegank ];
    platforms = lib.platforms.linux;
    broken = true; # requires godot_4-export-templates
  };
})

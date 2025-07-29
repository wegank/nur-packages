{
  lib,
  stdenv,
  fetchFromGitLab,
  rustPlatform,
  cargo,
  makeWrapper,
  godot_4,
  alsa-lib,
  libGL,
  libX11,
  libXcursor,
  libXext,
  libXi,
  libXinerama,
  libXrandr,
  libXrender,
  libpulseaudio,
  udev,
  vulkan-loader,
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
      --replace-fail "\$(wildcard /opt/godot-rust-cross-compiler.txt)" "yes"
    substituteInPlace godot/liquidwar7game.gdextension \
      --replace-fail ".x86_64" ""
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
    makeWrapper
    rustPlatform.bindgenHook
    rustPlatform.cargoSetupHook
  ];

  buildInputs = [
    alsa-lib
    libGL
    libX11
    libXcursor
    libXext
    libXi
    libXinerama
    libXrandr
    libXrender
    libpulseaudio
    udev
    vulkan-loader
  ];

  buildPhase = ''
    runHook preBuild

    export HOME=$(mktemp -d)
    cp -R ${godot_4.export-template} $HOME/.local
    chmod -R +w $HOME/.local

  ''
  + lib.optionalString (!stdenv.hostPlatform.isx86_64) ''
    pushd $HOME/.local/share/godot/export_templates/*/
    cp linux_release.* linux_release.x86_64
    popd

  ''
  + ''
    pushd rust
    cargo build --release
    install -Dm755 -t godot/gdnative/linux/${stdenv.hostPlatform.config} target/release/libliquidwar7game.so
    popd

    mkdir -p $out/share/liquidwar7
    for i in warmup real; do
      godot4 --headless --path godot --export-release "Linux/X11" $out/share/liquidwar7/liquidwar7
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    ln -s $out/share/liquidwar7/liquidwar7 $out/bin/liquidwar7
    wrapProgram $out/share/liquidwar7/liquidwar7 \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath finalAttrs.buildInputs}

    runHook postInstall
  '';

  meta = {
    description = "A distributed wargame";
    homepage = "https://gitlab.com/ufoot/liquidwar7";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ wegank ];
    platforms = lib.platforms.linux;
    broken = stdenv.hostPlatform.isDarwin;
  };
})

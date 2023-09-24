{ lib
, stdenv
, buildNpmPackage
, electron_19
, nodejs_16
, fetchFromGitHub
, autoPatchelfHook
, python3
, icu
, udev
, bash
, util-linux
}:

let
  electron = electron_19;
  nodejs = nodejs_16;
  buildNpmPackage' = buildNpmPackage.override {
    inherit nodejs;
  };
in
buildNpmPackage' rec {
  pname = "etcher";
  version = "1.18.11";

  src = fetchFromGitHub {
    owner = "balena-io";
    repo = "etcher";
    rev = "v${version}";
    hash = "sha256-Y1PTw7Yz3NAtW/IMm6Ko4qDJSr2Yy7G+SxN6K3b/C+Q=";
  };

  npmDepsHash = "sha256-Wlja8wwugoGMiauq04z56QEOj1Ks0SSE8nPS1+5DAXY=";

  makeCacheWritable = true;

  nativeBuildInputs = [
    autoPatchelfHook
    python3
  ];

  buildInputs = [
    icu
    nodejs.libv8
    stdenv.cc.cc.lib
    udev
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    NIX_LDFLAGS = "-lv8 -licui18n -licuuc";
  };

  postInstall = ''
    makeWrapper ${electron}/bin/electron $out/bin/etcher \
      --add-flags $out/lib/node_modules/balena-etcher \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"
  '';

  preFixup = ''
    substituteInPlace $out/lib/node_modules/balena-etcher/generated/gui.js \
      --replace '/usr/bin/pkexec' '/usr/bin/pkexec", "/run/wrappers/bin/pkexec' \
      --replace '/bin/bash' '${bash}/bin/bash' \
      --replace '"lsblk"' '"${util-linux}/bin/lsblk"'
  '';

  meta = with lib; {
    description = "Flash OS images to SD cards and USB drives, safely and easily";
    homepage = "https://etcher.io/";
    license = licenses.asl20;
    maintainers = with maintainers; [ wegank ];
    platforms = platforms.linux;
    broken = true;
  };
}

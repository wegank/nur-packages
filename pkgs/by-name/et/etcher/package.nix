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
  version = "1.18.12";

  src = fetchFromGitHub {
    owner = "balena-io";
    repo = "etcher";
    rev = "v${version}";
    hash = "sha256-Sn4WIYfDeF0qJSj+PpSmV/7aX7TX352Gvb4J+7teSSk=";
  };

  npmDepsHash = "sha256-s9aat4tTOXTkwGQ7ifMejIxJokEOeHQAYuTTn+2zne8=";

  npmPruneFlags = "--production";

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
      --add-flags $out/lib/node_modules/balena-etcher
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

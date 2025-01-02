{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  lua5_3,
  readline,
  SDL2,
  SDL2_image,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "casioemu";
  version = "0-unstable-2024-05-17";

  src = fetchFromGitHub {
    owner = "user202729";
    repo = "CasioEmu";
    rev = "52938b78451ff5f2409e95b00268f4d9d973dcdf";
    hash = "sha256-FRPVW3Z99YOFuJv8tM9aHmcxBhAM6wYlrRLZsZRLOsY=";
  };

  sourceRoot = "${finalAttrs.src.name}/emulator";

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    lua5_3
    readline
    SDL2
    SDL2_image
  ];

  postInstall = ''
    install -Dm755 emulator -t $out/bin
  '';

  meta = {
    description = "An emulator for nX-U8 based Casio fx-es PLUS calculators";
    homepage = "https://github.com/user202729/CasioEmu";
    licence = lib.licences.gpl3Only;
    maintainers = with lib.maintainers; [ wegank ];
    platforms = lib.platforms.unix;
  };
})

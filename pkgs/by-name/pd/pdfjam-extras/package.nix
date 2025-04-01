{
  lib,
  stdenv,
  fetchFromGitHub,
  makeBinaryWrapper,
  installShellFiles,
}:

stdenv.mkDerivation {
  pname = "pdfjam-extras";
  version = "0-unstable-2019-11-18";

  src = fetchFromGitHub {
    owner = "pdfjam";
    repo = "pdfjam-extras";
    rev = "622e03add59db004144c0b41722a09b3b29d6d3e";
    hash = "sha256-2aSqd1A8Y53UWaOkAgfqJEGw50EM/I9VIqyYxPq5c/s=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    installShellFiles
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 -t $out/bin bin/*
    installManPage man1/*

    runHook postInstall
  '';

  meta = {
    description = "Some unsupported 'wrapper' scripts for pdfjam";
    homepage = "https://github.com/pdfjam/pdfjam-extras";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ wegank ];
    platforms = lib.platforms.all;
  };
}

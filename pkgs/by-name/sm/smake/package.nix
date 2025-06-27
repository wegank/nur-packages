{
  lib,
  stdenv,
  fetchurl,
  installShellFiles,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "smake";
  version = "2024-03-21";

  src = fetchurl {
    url = "https://codeberg.org/schilytools/schilytools/releases/download/${finalAttrs.version}/schily-${finalAttrs.version}.tar.bz2";
    hash = "sha256-dtsCLkUMF5GgDml4C1XRii4/w5tf+HCZZDP4cxIDICQ=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    pushd psmake
    ./MAKE-all
    popd

    for dir in libschily smake man; do
      pushd $dir
      ../psmake/smake
      popd
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 smake/OBJ/*/smake $out/bin/smake
    installManPage smake/OBJ/*/*/*.1 man/man5/OBJ/*/*/*.5

    runHook postInstall
  '';

  meta = {
    description = "Portable make program with automake features";
    homepage = "https://codeberg.org/schilytools/schilytools";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ wegank ];
    platforms = lib.platforms.all;
  };
})

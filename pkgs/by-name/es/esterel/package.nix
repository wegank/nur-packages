{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "esterel";
  version = "5.92";

  src = fetchurl {
    url = "https://www-sop.inria.fr/esterel.org/files/Html/Downloads/Soft/esterelv${
      builtins.replaceStrings [ "." ] [ "_" ] finalAttrs.version
    }.linux.tgz";
    hash = "sha256-Wq5IbytQLWLdxKdnh72P0TiwhYIIEwFRt47Es2gi+TM=";
  };

  sourceRoot = ".";

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -R * $out
    substituteInPlace $out/bin/{esterel,sscdebug,xes,xeve}{,.orig} \
      --replace "../esterelv5_92.linux" "$out"

    runHook postInstall
  '';

  meta = with lib; {
    description = "A Synchronous Reactive Programming Language";
    homepage = "https://www-sop.inria.fr/esterel.org/files/";
    license = licenses.unfree;
    maintainers = with maintainers; [ wegank ];
    platforms = platforms.linux;
  };
})

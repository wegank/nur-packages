{
  lib,
  stdenv,
  pkgs,
  fetchFromGitHub,
  mpfr,
  rWrapper,
  writableTmpDirAsHomeHook,
}:

(pkgs.macaulay2.override {
  downloadDocs = false;
}).overrideAttrs
  (
    finalAttrs: previousAttrs: {
      version = "1.26.06-unstable-2026-11-13";

      src = fetchFromGitHub {
        owner = "Macaulay2";
        repo = "M2";
        rev = "ba27e7761c9def7982adc382d4120d4e9a914980";
        hash = "sha256-R6jVT1zu7sZcy0vLBU+x8m9KRPl5fR6M6yS4uxMg+xE=";
      };

      nativeBuildInputs = (previousAttrs.nativeBuildInputs or [ ]) ++ [
        writableTmpDirAsHomeHook
      ];

      preBuild = (previousAttrs.preBuild or "") + ''
        addToSearchPath ${
          if stdenv.hostPlatform.isDarwin then "DYLD_LIBRARY_PATH" else "LD_LIBRARY_PATH"
        } ${lib.getLib mpfr}/lib
        export R_LIBS_SITE=${lib.makeSearchPath "library" rWrapper.recommendedPackages}''${R_LIBS_SITE:+:$R_LIBS_SITE}
      '';
    }
  )

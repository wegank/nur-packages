{ lib
, stdenvNoCC
, fetchurl
, unzip
}:

stdenvNoCC.mkDerivation rec {
  pname = "skinlf";
  version = "6.7";

  src = fetchurl {
    url = "https://sources.archlinux.org/other/community/java-skinlf/skinlf-6.7-20060722.zip";
    hash = "sha256-PTH/vh+hMlBJy5TmdZcaK42JriRVjLFz5+Th+Sbdfao=";
  };

  nativeBuildInputs = [
    unzip
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/java
    cp lib/{nativeskin,skinlf}.jar $out/share/java

    runHook postInstall
  '';

  meta = with lib; {
    description = "Skinning engine for Swing";
    homepage = "https://aur.archlinux.org/packages/java-skinlf";
    license = licenses.asl20;
    maintainers = with maintainers; [ wegank ];
    platforms = platforms.unix;
  };
}

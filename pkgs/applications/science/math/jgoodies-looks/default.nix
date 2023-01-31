{ lib
, stdenvNoCC
, fetchurl
, unzip
}:

stdenvNoCC.mkDerivation rec {
  pname = "jgoodies-looks";
  version = "2.5.3";

  src = fetchurl {
    url = "https://www.jgoodies.com/download/libraries/looks/jgoodies-looks-2_5_3.zip";
    hash = "sha256-pKYfXVR04EjBLWAtyJnyvPe0FgTVcEiA61rxS0k4xYg=";
  };

  nativeBuildInputs = [
    unzip
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/java
    cp jgoodies-looks-${version}.jar $out/share/java/jgoodies-looks.jar

    runHook postInstall
  '';

  meta = with lib; {
    description = "A Java Swing look and feel library";
    homepage = "https://github.com/jgraph/jgraphx";
    license = licenses.bsd3;
    maintainers = with maintainers; [ wegank ];
    platforms = platforms.unix;
  };
}

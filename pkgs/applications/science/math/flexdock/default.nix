{ lib
, stdenv
, fetchurl
, ant
, openjdk
}:

stdenv.mkDerivation rec {
  pname = "flexdock";
  version = "1.2.4";

  src = fetchurl {
    url = "https://src.fedoraproject.org/repo/pkgs/flexdock/flexdock-1.2.4.tar.gz/79883baeb9d628d45fa4d16897f6d96b/flexdock-1.2.4.tar.gz";
    hash = "sha256-/wODkpxTc99sFLoyGSO1ZoAjszwDRcHosbRuBWUw/aI=";
  };

  postPatch = ''
    substituteInPlace build.xml \
      --replace "1.5" "1.7"
  '';

  nativeBuildInputs = [
    ant
    openjdk
  ];

  buildPhase = ''
    runHook preBuild

    ant

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/java
    cp build/${pname}-${version}.jar $out/share/java/${pname}.jar

    runHook postInstall
  '';

  meta = with lib; {
    description = "Java docking framework for use in cross-platform Swing applications";
    homepage = "https://github.com/opencollab/flexdock";
    license = licenses.asl20;
    maintainers = with maintainers; [ wegank ];
    platforms = platforms.unix;
  };
}

{ lib
, stdenv
, fetchFromGitHub
, ant
, openjdk
}:

stdenv.mkDerivation rec {
  pname = "jgraphx";
  version = "4.2.2";

  src = fetchFromGitHub {
    owner = "jgraph";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-n1eDQMPB3XwiwCDncAN6wSYQsSAOUaENhp56xbwZhdc=";
  };

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
    cp lib/jgraphx.jar $out/share/java

    runHook postInstall
  '';

  meta = with lib; {
    description = "A Java Swing diagramming (graph visualisation) library";
    homepage = "https://github.com/jgraph/jgraphx";
    license = licenses.bsd3;
    maintainers = with maintainers; [ wegank ];
    platforms = platforms.unix;
  };
}

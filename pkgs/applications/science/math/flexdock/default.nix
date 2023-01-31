{ lib
, stdenv
, fetchFromGitHub
, ant
, openjdk
}:

stdenv.mkDerivation rec {
  pname = "flexdock";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "opencollab";
    repo = pname;
    rev = version;
    hash = "sha256-ae6atAa84mj0fZ9O6YhM864k/7Jdqdxt4o+C4Fj79UM=";
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
    description = "Java Swing diagramming (graph visualisation) library";
    homepage = "https://github.com/jgraph/jgraphx";
    license = licenses.bsd3;
    maintainers = with maintainers; [ wegank ];
    platforms = platforms.unix;
  };
}

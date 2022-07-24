{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, libxkbcommon
, wayland
, bootstrap_cmds
, Cocoa
}:

stdenv.mkDerivation rec {
  pname = "owl-compositor";
  version = "0.0.20211110";

  src = fetchFromGitHub {
    owner = pname;
    repo = "owl";
    rev = "91abf02613cd2ddb97be58b5b6703240320233a0";
    sha256 = "sha256-a+TznasOVEzSNrs66/y91AeMRDEfyd+WO5mO811hLj0=";
  };

  prePatch = lib.optionalString stdenv.isDarwin ''
    sed -i "181s/ibtool/\/usr\/bin\/ibtool/" configure
    sed -i "201,202d;204,209d" configure
  '';

  # requires ibtool
  sandboxProfile = lib.optionalString stdenv.isDarwin ''
    (allow process-exec
      (literal "/usr/bin/ibtool")
      (regex "/Xcode.app/Contents/Developer/usr/bin/ibtool")
      (regex "/Xcode.app/Contents/Developer/usr/bin/xcodebuild"))
    (allow file-read*)
    (deny file-read* (subpath "/usr/local") (with no-log))
    (allow file-write* (subpath "/private/var/folders"))
  '';

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    libxkbcommon
    wayland
  ] ++ lib.optionals stdenv.isDarwin [
    bootstrap_cmds
    Cocoa
  ];

  preConfigure = ''
    mkdir build
    cd build
  '';

  configureScript = "../configure";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications $out/bin
    mv Owl.app $out/Applications
    makeWrapper $out/Applications/Owl.app/Contents/MacOS/Owl $out/bin/Owl
    runHook postInstall
  '';

  meta = with lib; {
    description = "A portable Wayland compositor in Objective-C";
    homepage = "https://github.com/owl-compositor/owl";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
    broken = stdenv.isLinux;
    maintainers = with maintainers; [ wegank ];
  };
}

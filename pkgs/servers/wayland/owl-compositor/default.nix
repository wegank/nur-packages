{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, libxkbcommon
, wayland
, DarwinTools
, bootstrap_cmds
, Cocoa
}:

stdenv.mkDerivation rec {
  pname = "owl-compositor";
  version = "unstable-2021-11-10";

  src = fetchFromGitHub {
    owner = pname;
    repo = "owl";
    rev = "91abf02613cd2ddb97be58b5b6703240320233a0";
    sha256 = "sha256-a+TznasOVEzSNrs66/y91AeMRDEfyd+WO5mO811hLj0=";
  };

  postPatch = lib.optionalString stdenv.isDarwin ''
    sed -i "/ibtool/d" configure
    mkdir -p build/Owl.app/Contents/Resources/English.lproj
    cp ${./mac/MainMenu.nib} build/Owl.app/Contents/Resources/English.lproj/MainMenu.nib
    cp ${./mac/OwlPreferences.nib} build/Owl.app/Contents/Resources/English.lproj/OwlPreferences.nib
  '';

  nativeBuildInputs = [
    makeWrapper
  ] ++ lib.optionals stdenv.isDarwin [
    DarwinTools
    bootstrap_cmds
  ];

  buildInputs = [
    libxkbcommon
    wayland
  ] ++ lib.optionals stdenv.isDarwin [
    Cocoa
  ];

  preConfigure = ''
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

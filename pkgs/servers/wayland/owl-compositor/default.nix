{ lib
, stdenv
, gnustep
, fetchFromGitHub
, makeWrapper
, darwin
, libxkbcommon
, wayland
}:

let
  mkDerivation = if stdenv.isDarwin then stdenv.mkDerivation else gnustep.gsmakeDerivation;
in
mkDerivation {
  pname = "owl-compositor";
  version = "unstable-2021-11-10";

  src = fetchFromGitHub {
    owner = "owl-compositor";
    repo = "owl";
    rev = "91abf02613cd2ddb97be58b5b6703240320233a0";
    sha256 = "sha256-a+TznasOVEzSNrs66/y91AeMRDEfyd+WO5mO811hLj0=";
  };

  prePatch = lib.optionalString stdenv.isDarwin ''
    sed -i "/ibtool/d" configure
    mkdir -p build/Owl.app/Contents/Resources/English.lproj
    cp ${./mac/MainMenu.nib} build/Owl.app/Contents/Resources/English.lproj/MainMenu.nib
    cp ${./mac/OwlPreferences.nib} build/Owl.app/Contents/Resources/English.lproj/OwlPreferences.nib
  '';

  postPatch = ''
    mkdir -p build
    cd build
  '';

  nativeBuildInputs = [
    makeWrapper
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.DarwinTools
    darwin.bootstrap_cmds
  ] ++ lib.optionals (!stdenv.isDarwin) [
    gnustep.make
  ];

  buildInputs = [
    libxkbcommon
    wayland
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Cocoa
  ] ++ lib.optionals (!stdenv.isDarwin) [
    gnustep.back
    gnustep.base
    gnustep.gui
  ];

  # error: "Your gnustep-base was configured for the objc-nonfragile-abi but you are not using it now."
  env.NIX_CFLAGS_COMPILE = lib.optionalString (!stdenv.isDarwin) "-fobjc-runtime=gnustep-2.0";

  configureScript = "../configure";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications $out/bin
    mv Owl.app $out/Applications
    makeWrapper $out/Applications/Owl.app/${lib.optionalString stdenv.isDarwin "Contents/MacOS/"}Owl $out/bin/Owl

    runHook postInstall
  '';

  meta = with lib; {
    description = "A portable Wayland compositor in Objective-C";
    homepage = "https://github.com/owl-compositor/owl";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
    maintainers = with maintainers; [ wegank ];
  };
}

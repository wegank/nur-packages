{ fetchgit
, lib
, mkYarnModules
, nodejs
, pkgs ? import <nixpkgs> { }
, stdenv
, yarn
}:

let
  pname = "perpetual-pools-client";
  version = "0.1.0";

  src = fetchgit {
    url = "https://github.com/tracer-protocol/pools-client.git";
    rev = "9c7420b293a3450fd88ff5d29dbedb50ff429523";
    sha256 = "sha256-ykmavWJqPANPJZ0vKp/OiGmlJ/jyZfHyOFOP959MUEY=";
    postFetch = ''
      cd $out
      patch -p1 < ${./fix-yarn-lock.patch}
    '';
  };

  yarnDeps = mkYarnModules {
    pname = "${pname}-yarn-deps";
    inherit version;
    packageJSON = "${src}/package.json";
    yarnLock = "${src}/yarn.lock";
    yarnNix = ./yarn.nix;
  };
in
stdenv.mkDerivation rec {
  inherit pname version src;

  nativeBuildInputs = [
    nodejs
    yarn
  ];

  patchPhase = ''
    sed -i '$i experimental: { outputStandalone: true, },' next.config.js
  '';

  buildPhase = ''
    cp -R ${yarnDeps}/node_modules .
    yarn build
  '';

  doCheck = false;

  installPhase = ''
    mkdir -p $out/share/${pname}
    cp -LR .next/standalone/. $out/share/${pname}
    cp -R public $out/share/${pname}
    cp -R .next/static $out/share/${pname}/.next/
  '';

  meta = with lib; {
    homepage = "https://github.com/tracer-protocol/pools-client";
    description = "Client interface for Perpetual Pools";
    # maintainers = with maintainers; [ wegank ];
    platforms = platforms.unix;
  };
}
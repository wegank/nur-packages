{ fetchgit
, lib
, mkYarnModules
, nodejs
, pkgs ? import <nixpkgs> { }
, pongified ? false
, pools ? [ ]
, stdenv
, yarn
}:

let
  version = "0.1.0";

  srcTracer = fetchgit {
    url = "https://github.com/tracer-protocol/pools-client.git";
    rev = "9c7420b293a3450fd88ff5d29dbedb50ff429523";
    sha256 = "sha256-ykmavWJqPANPJZ0vKp/OiGmlJ/jyZfHyOFOP959MUEY=";
    postFetch = ''
      cd $out
      patch -p1 < ${./fix-yarn-lock.patch}
    '';
  };

  srcPong = fetchgit {
    url = "https://github.com/wegank/pools-client.git";
    rev = "1ec15aba90e620add1da3790ea215d982655e200";
    sha256 = "sha256-upBPmXS9KkX3/HgfWjbyEYDBqDDHh32goRaOTfgUeT0=";
  };

  yarnDeps = mkYarnModules {
    pname = "perpetual-pools-client-yarn-deps";
    inherit version;
    packageJSON = "${srcTracer}/package.json";
    yarnLock = "${srcTracer}/yarn.lock";
    yarnNix = ./yarn.nix;
  };
in
stdenv.mkDerivation rec {
  pname = if pongified then "pong-client" else "perpetual-pools-client";
  src = if pongified then srcPong else srcTracer;
  inherit version;

  buildInputs = [ nodejs ];

  nativeBuildInputs = [ yarn ];

  patchPhase = ''
    sed -i '$i experimental: { outputStandalone: true, },' next.config.js
  '';

  buildPhase = ''
    cp -R ${yarnDeps}/node_modules .
    NEXT_PUBLIC_POOL_ADDRESSES="${lib.concatStringsSep "," pools}" yarn build
  '';

  doCheck = false;

  installPhase = ''
    mkdir -p $out/bin $out/share/${pname}
    cp -LR .next/standalone/. $out/share/${pname}
    cp -R public $out/share/${pname}
    cp -R .next/static $out/share/${pname}/.next/
    sed -i '1i#!/usr/bin/env node' $out/share/${pname}/server.js
    chmod +x $out/share/${pname}/server.js
    ln -s $out/share/${pname}/server.js $out/bin/${pname}
  '';

  meta = with lib; {
    homepage = "https://github.com/tracer-protocol/pools-client";
    description = "Client interface for Perpetual Pools";
    # maintainers = with maintainers; [ wegank ];
    platforms = platforms.unix;
  };
}

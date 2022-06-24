{ fetchFromGitHub
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

  src = fetchFromGitHub {
    owner = "tracer-protocol";
    repo = "pools-client";
    rev = "6ff88da0d86afafa50bb0a135f69b74eb39392ef";
    sha256 = "sha256-8fkY4MOIpyyZlwDPmkT1f6YWS62ylIk2WUY0kMTLIME=";
  };

  yarnDeps = mkYarnModules {
    pname = "${pname}-yarn-deps";
    inherit version;
    packageJSON = ./package.json;
    yarnLock = ./yarn.lock;
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

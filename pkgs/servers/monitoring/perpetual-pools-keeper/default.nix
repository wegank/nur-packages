{ fetchFromGitHub
, lib
, mkYarnModules
, nodejs
, stdenv
, yarn
}:

let
  pname = "perpetual-pools-keeper";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "tracer-protocol";
    repo = "perpetual-pools-v2-keeper-ts";
    rev = "8f4c5762c11e6bf5757733d411849603dccd23f0";
    sha256 = "sha256-EGe9o8u5QeosM+C2WPUHmETNoZ8dvhnt6SoaOrb12rw=";
  };

  packageJSON = "${src}/package.json";
  yarnLock = "${src}/yarn.lock";
  yarnNix = ./yarn.nix;

  yarnDepsDev = mkYarnModules {
    pname = "${pname}-yarn-deps-dev";
    inherit version packageJSON yarnLock yarnNix;
  };

  yarnDeps = mkYarnModules {
    pname = "${pname}-yarn-deps";
    inherit version packageJSON yarnLock yarnNix;
    yarnFlags = [ "--offline" "--production" ];
  };
in
stdenv.mkDerivation rec {
  inherit pname version src;

  buildInputs = [ nodejs ];

  nativeBuildInputs = [ yarn ];

  buildPhase = ''
    ln -sf ${yarnDepsDev}/node_modules .
    yarn tsc
  '';

  doCheck = false;

  installPhase = ''
    mkdir -p $out/bin $out/share/${pname}
    cp -LR ${yarnDeps}/node_modules $out/share/${pname}
    cp -R build/. $out/share/${pname}
    sed -i '1i#!/usr/bin/env node' $out/share/${pname}/index.js
    chmod +x $out/share/${pname}/index.js
    ln -s $out/share/${pname}/index.js $out/bin/${pname}
  '';

  meta = with lib; {
    homepage = "https://github.com/tracer-protocol/perpetual-pools-v2-keeper-ts";
    description = "Typescript keeper bot for perpetual pools v2";
    maintainers = with maintainers; [ wegank ];
    platforms = platforms.unix;
  };
}

{ fetchFromGitHub
, lib
, mkYarnModules
, nodejs
, pkgs ? import <nixpkgs> { }
, stdenv
, yarn
}:

let
  pname = "perpetual-pools-keeper";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "tracer-protocol";
    repo = "perpetual-pools-v2-keeper-ts";
    rev = "bda8ebc97e7110581fc08843ff27ad316efae4bc";
    sha256 = "sha256-zWclDnwSnrasrPiZolxjUCv8+HK6S6kLbLyWf91rUxU=";
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

  buildPhase = ''
    ln -sf ${yarnDeps}/node_modules .
    yarn tsc
  '';

  doCheck = false;

  installPhase = ''
    mkdir -p $out/share/${pname}
    cp -R build/. $out/share/${pname}
  '';

  meta = with lib; {
    homepage = "https://github.com/tracer-protocol/perpetual-pools-v2-keeper-ts";
    description = "Typescript keeper bot for perpetual pools v2";
    # maintainers = with maintainers; [ wegank ];
    platforms = platforms.unix;
  };
}

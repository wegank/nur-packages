{ fetchgit
, lib
, mkYarnModules
, nodejs
, nodePackages
, stdenv
, yarn

, api ? "https://api.tracer.finance"
, pongified ? false
, pools ? [ ]
, testnetRpc ? "https://rinkeby.arbitrum.io/rpc"
, testnetWssRpc ? "wss://arb-rinkeby.g.alchemy.com/v2/dFgGxwP6yyYQJuqCbQjHGSyIuhLp1Xmz"
}:

let
  name = if pongified then "pong-client" else "perpetual-pools-client";
  version = "0.1.0";

  srcTracer = fetchgit {
    url = "https://github.com/tracer-protocol/pools-client.git";
    rev = "4797392d8b7e50eaa932ea6c9afc58d04d110308";
    sha256 = "sha256-AwcUA6eZIHX4T/fO0ZTAjlNjuzJuAASVMEZAJtaUTa4=";
    postFetch = ''
      cd $out
      patch -p1 < ${./fix-yarn-lock.patch}
    '';
  };

  srcPong = fetchgit {
    url = "https://github.com/wegank/pools-client.git";
    rev = "495e4be39bbaff1accc03ca51648dfcfd7f4ce7a";
    sha256 = "sha256-eVbSZB+lJOlHRVuG/b531OEA9qv8mgsGbCjaCiWPhvE=";
  };

  src = if pongified then srcPong else srcTracer;

  yarnDeps = mkYarnModules {
    pname = "${name}-yarn-deps";
    inherit version;
    packageJSON = "${src}/package.json";
    yarnLock = "${src}/yarn.lock";
    yarnNix = ./yarn.nix;
    postBuild = lib.optionalString pongified ''
      cd $out
      for patch in ${src}/patches/*.patch; do
        patch -p1 < $patch
      done
    '';
  };

  defaultPool = "0x2150D5fF4Fc13bf427183a97Dba7901Ce54471A8";

  cachedLayer = stdenv.mkDerivation rec {
    pname = "${name}-cached";
    inherit src version;

    nativeBuildInputs = [ nodejs yarn ];

    buildPhase = ''
      ln -s ${yarnDeps}/node_modules node_modules
      export NEXT_PUBLIC_POOL_ADDRESSES="${defaultPool}"
      export NEXT_PUBLIC_TESTNET_RPC=${testnetRpc}
      export NEXT_PUBLIC_TESTNET_WSS_RPC=${testnetWssRpc}
      export NEXT_PUBLIC_TRACER_API=${api}
      yarn build
      yarn export
    '';

    doCheck = false;

    installPhase = ''
      mkdir -p $out/share/${pname}
      cp -LR out/. $out/share/${pname}
    '';
  };
in
stdenv.mkDerivation rec {
  pname = name;
  src = cachedLayer;
  inherit version;

  buildInputs = [ nodePackages.serve ];

  buildPhase = ''
    mkdir -p $out/share/${pname}
    cp -LR $src/share/${pname}-cached/. $out/share/${pname}
    chmod +w $out/share/${pname}/_next/static/chunks/pages/.
    sed -i 's/${defaultPool}/${lib.concatStringsSep "," pools}/g' $out/share/${pname}/_next/static/chunks/pages/*
  '';

  doCheck = false;

  installPhase = ''
    mkdir -p $out/bin
    printf "#!/usr/bin/env bash\n${nodePackages.serve}/bin/serve $out/share/${pname}" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';

  meta = with lib; {
    homepage = "https://github.com/tracer-protocol/pools-client";
    description = "Client interface for Perpetual Pools";
    # maintainers = with maintainers; [ wegank ];
    platforms = platforms.unix;
  };
}

{
  lib,
  stdenv,
  pkgs,
  epoll-shim,
  darwin,
}:

pkgs.havoc.overrideAttrs (old: {
  patches = [
    ./darwin.patch
  ];

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace Makefile \
      --replace "-lrt" ""
  '';

  buildInputs =
    old.buildInputs
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      darwin.libutil
    ];

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    NIX_CFLAGS_COMPILE = toString [
      "-Wno-error=implicit-function-declaration"
      "-I${epoll-shim}/include/libepoll-shim"
    ];
    NIX_CFLAGS_LINK = "-L${epoll-shim}/lib -lepoll-shim";
  };

  meta.platforms = lib.platforms.unix;
})

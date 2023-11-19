{ lib
, stdenv
, havoc
, epoll-shim
}:

havoc.overrideAttrs (old: {
  patches = [
    ./darwin.patch
  ];

  postPatch = lib.optionalString stdenv.isDarwin ''
    substituteInPlace Makefile \
      --replace "-lrt" ""
  '';

  env = lib.optionalAttrs stdenv.isDarwin {
    NIX_CFLAGS_COMPILE = toString [
      "-Wno-error=implicit-function-declaration"
      "-I${epoll-shim}/include/libepoll-shim"
    ];
    NIX_CFLAGS_LINK = "-L${epoll-shim}/lib -lepoll-shim";
  };

  meta.platforms = lib.platforms.unix;
})

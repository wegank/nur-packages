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

  env = {
    NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-I${epoll-shim}/include/libepoll-shim";
    NIX_CFLAGS_LINK = lib.optionalString stdenv.isDarwin "-L${epoll-shim}/lib -lepoll-shim";
  };

  meta.platforms = lib.platforms.unix;
})

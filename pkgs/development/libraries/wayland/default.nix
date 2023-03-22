{ lib
, stdenv
, wayland
, epoll-shim
, darwin
}:

(wayland.overrideAttrs (old: {
  patches = old.patches or [ ] ++ lib.optionals (!stdenv.isLinux) [
    ./darwin.patch
  ];

  buildInputs = old.buildInputs ++ lib.optionals (!stdenv.isLinux) [
    epoll-shim
  ];

  meta.platforms = lib.platforms.unix;
})).override {
  stdenv = if stdenv.isDarwin then darwin.apple_sdk_11_0.stdenv else stdenv;
  withLibraries = true;
}

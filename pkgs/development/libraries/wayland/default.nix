{ lib
, stdenv
, wayland
, epoll-shim
, darwin
}:

(wayland.overrideAttrs (old: {
  patches = old.patches or [ ] ++ [
    ./darwin.patch
  ];

  meta.platforms = lib.platforms.unix;
})).override {
  stdenv = if stdenv.isDarwin then darwin.apple_sdk_11_0.stdenv else stdenv;
  withLibraries = true;
}

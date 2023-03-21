{ lib
, stdenv
, wayland
, epoll-shim
}:

(wayland.overrideAttrs (old: {
  patches = old.patches or [ ] ++ lib.optionals (!stdenv.isLinux) [
    ./fix-build-on-darwin.patch
  ];

  buildInputs = old.buildInputs ++ lib.optionals (!stdenv.isLinux) [
    epoll-shim
  ];

  meta.platforms = lib.platforms.unix;
})).override {
  withLibraries = true;
}

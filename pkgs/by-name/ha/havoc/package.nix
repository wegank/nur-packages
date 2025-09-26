{
  lib,
  stdenv,
  pkgs,
  epoll-shim,
  darwin,
}:

let
  wayland = pkgs.wayland.overrideAttrs (
    finalAttrs: oldAttrs: {
      patches = [
        ./wayland-darwin.patch
      ];
      meta = oldAttrs.meta // {
        broken = false;
      };
    }
  );
  wayland-protocols = pkgs.wayland-protocols.override {
    inherit wayland;
  };
  wayland-scanner = pkgs.wayland-scanner.override {
    inherit wayland;
  };
in
(pkgs.havoc.override {
  inherit
    wayland
    wayland-protocols
    wayland-scanner
    ;
}).overrideAttrs
  (old: {
    patches = [
      ./havoc-darwin.patch
    ];

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

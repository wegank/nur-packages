{
  lib,
  stdenv,
  pkgs,
  epoll-shim,
  darwin,
  fetchurl,
  mdbook,
}:

let
  version = "1.25.0";
  src = fetchurl {
    url = "https://gitlab.freedesktop.org/wayland/wayland/-/releases/${version}/downloads/wayland-${version}.tar.xz";
    hash = "sha256-wGXwQK/f8xd2gGAPJJcn5Boa/CL8zyciLxX1MG+qHwM=";
  };
  wayland-scanner = pkgs.wayland-scanner.override {
    inherit wayland;
  };
  wayland = (pkgs.wayland.override { inherit wayland-scanner; }).overrideAttrs (
    finalAttrs: oldAttrs: {
      inherit version src;
      patches = [
        # https://gitlab.freedesktop.org/wayland/wayland/-/merge_requests/508
        ./wayland-darwin.patch
      ];
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
        mdbook
      ];
      meta = oldAttrs.meta // {
        badPlatforms = [ ];
      };
    }
  );
  wayland-protocols = pkgs.wayland-protocols.override {
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

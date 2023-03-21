{ lib
, stdenv
, wayland-protocols
, wayland
, wayland-scanner
}:

(wayland-protocols.overrideAttrs (old: {
  postPatch = old.postPatch + lib.optionalString stdenv.isDarwin ''
    sed -i "90iif not protocol_file.contains('xdg-decoration-unstable-v1')" tests/meson.build
    sed -i '118iendif' tests/meson.build
  '';
})).override {
  inherit wayland wayland-scanner;
}

# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

with pkgs;

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Aegisub
  aegisub = callPackage ./pkgs/applications/video/aegisub {
    wxGTK = wxGTK31;
    inherit (darwin.apple_sdk.frameworks) CoreText CoreFoundation AppKit Carbon IOKit Cocoa;
  };

  # Electronics
  flopoco = callPackage ./pkgs/applications/science/electronics/flopoco { };
  nvc = callPackage ./pkgs/applications/science/electronics/nvc { };
  pagsuite = callPackage ./pkgs/development/libraries/science/electronics/pagsuite { };
  scalp = callPackage ./pkgs/development/libraries/science/electronics/scalp { };
  sollya = callPackage ./pkgs/development/interpreters/sollya { };
  wcpg = callPackage ./pkgs/development/libraries/science/electronics/wcpg { };

  # Perpetual Pools
  perpetual-pools-keeper = callPackage ./pkgs/servers/monitoring/perpetual-pools-keeper { };
  perpetual-pools-client = callPackage ./pkgs/servers/web-apps/perpetual-pools-client { };
  pong-client = callPackage ./pkgs/servers/web-apps/perpetual-pools-client {
    pongified = true;
  };

  # UxPlay
  a52dec = callPackage ./pkgs/development/libraries/a52dec { };
  uxplay = callPackage ./pkgs/servers/uxplay/default.nix {
    a52dec = callPackage ./pkgs/development/libraries/a52dec { };
  };

  # Misc
  mpvpaper = callPackage ./pkgs/applications/graphics/mpvpaper/default.nix { };

  # some-qt5-package = libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}

# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

with pkgs;

let
  scalp = callPackage ./pkgs/development/libraries/science/electronics/scalp { };
  pagsuite = callPackage ./pkgs/development/libraries/science/electronics/pagsuite {
    inherit scalp;
  };
in
{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Electronics
  flopoco = callPackage ./pkgs/applications/science/electronics/flopoco {
    inherit pagsuite scalp;
  };
  inherit pagsuite scalp;

  # Perpetual Pools
  perpetual-pools-keeper = callPackage ./pkgs/servers/monitoring/perpetual-pools-keeper { };
  perpetual-pools-client = callPackage ./pkgs/servers/web-apps/perpetual-pools-client { };
  pong-client = callPackage ./pkgs/servers/web-apps/perpetual-pools-client {
    pongified = true;
  };

  # Pinephone
  eg25-manager = pkgs.callPackage ./pkgs/applications/networking/eg25-manager { };
  linux_pinephone = pkgs.callPackage ./pkgs/os-specific/linux/kernel/linux-pinephone.nix { };
  pinephone-firmware = pkgs.callPackage ./pkgs/os-specific/linux/firmware/pinephone-firmware { };

  # UxPlay
  a52dec = callPackage ./pkgs/development/libraries/a52dec { };
  uxplay = callPackage ./pkgs/servers/uxplay/default.nix {
    a52dec = callPackage ./pkgs/development/libraries/a52dec { };
  };

  # Wayland
  epoll-shim = callPackage ./pkgs/development/libraries/epoll-shim { };
  wayland = callPackage ./pkgs/development/libraries/wayland {
    epoll-shim = callPackage ./pkgs/development/libraries/epoll-shim { };
  };

  # Misc
  mpvpaper = callPackage ./pkgs/applications/graphics/mpvpaper/default.nix { };

  # some-qt5-package = libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}

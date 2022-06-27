# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Electronics
  nvc = pkgs.callPackage ./pkgs/applications/science/electronics/nvc { };
  wcpg = pkgs.callPackage ./pkgs/development/libraries/wcpg { };

  # Perpetual Pools
  perpetual-pools-keeper = pkgs.callPackage ./pkgs/servers/monitoring/perpetual-pools-keeper { };
  perpetual-pools-client = pkgs.callPackage ./pkgs/servers/web-apps/perpetual-pools-client { };
  pong-client = pkgs.callPackage ./pkgs/servers/web-apps/perpetual-pools-client {
    pongified = true;
  };

  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}

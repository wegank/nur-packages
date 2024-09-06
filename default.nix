# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;

let
  # Misc
  godot_4-export-templates = callPackage ./pkgs/by-name/go/godot_4-export-templates/package.nix { };
in
{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Wayland
  havoc = callPackage ./pkgs/by-name/ha/havoc/package.nix { };

  # Misc
  drgeo = callPackage ./pkgs/by-name/dr/drgeo/package.nix { };
  etcher = callPackage ./pkgs/by-name/et/etcher/package.nix { };
  ftk = callPackage ./pkgs/by-name/ft/ftk/package.nix { };
  inherit godot_4-export-templates;
  ioh = python3Packages.callPackage ./pkgs/by-name/io/ioh/package.nix { };
  liquidwar7 = callPackage ./pkgs/by-name/li/liquidwar7/package.nix {
    inherit godot_4-export-templates;
  };

  # Synchronous systems
  esterel = callPackage ./pkgs/by-name/es/esterel/package.nix { };
  velus = callPackage ./pkgs/by-name/ve/velus/package.nix { };

  # Pinephone
  linux-pinephone = pkgs.callPackage ./pkgs/by-name/li/linux-pinephone/package.nix { };
  pinephone-firmware = callPackage ./pkgs/by-name/pi/pinephone-firmware/package.nix { };
}

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

  # Wayland
  havoc = callPackage ./pkgs/applications/terminal-emulators/havoc { };

  # Misc
  etcher = callPackage ./pkgs/by-name/et/etcher/package.nix { };
  snapshot = callPackage ./pkgs/desktops/gnome/apps/snapshot { };

  # Synchronous systems
  esterel = callPackage ./pkgs/by-name/es/esterel/package.nix { };
  velus = callPackage ./pkgs/by-name/ve/velus/package.nix { };
  zelus = callPackage ./pkgs/by-name/ze/zelus/package.nix { };

} // pkgs.lib.optionalAttrs (pkgs.stdenv.isAarch64 && pkgs.stdenv.isLinux) {
  # Pinephone
  eg25-manager = pkgs.callPackage ./pkgs/applications/networking/eg25-manager { };
  linux_pinephone = pkgs.callPackage ./pkgs/os-specific/linux/kernel/linux-pinephone.nix { };
  pinephone-firmware = pkgs.callPackage ./pkgs/os-specific/linux/firmware/pinephone-firmware { };
}

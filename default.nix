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
  # Robotics
  eigenpy = python3Packages.callPackage ./pkgs/development/python-modules/eigenpy { };
  pinocchio = python3Packages.callPackage ./pkgs/development/python-modules/pinocchio {
    inherit eigenpy;
  };

  pyngrok = python3Packages.callPackage ./pkgs/development/python-modules/pyngrok { };
  meshcat = python3Packages.callPackage ./pkgs/development/python-modules/meshcat {
    inherit pyngrok;
  };

  # Wayland
  epoll-shim = callPackage ./pkgs/development/libraries/epoll-shim { };
  epoll-shim-hook = epoll-shim.override {
    itimerspecHook = true;
    atomicCloseOnExecHook = true;
  };
  wayland = darwin.apple_sdk_11_0.callPackage ./pkgs/development/libraries/wayland {
    epoll-shim = epoll-shim-hook;
  };
  wayland-protocols = callPackage ./pkgs/development/libraries/wayland/protocols.nix {
    inherit wayland wayland-scanner;
  };
  wayland-scanner = wayland.bin;
in
{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Electronics
  flopoco = callPackage ./pkgs/applications/science/electronics/flopoco { };

  # Perpetual Pools
  perpetual-pools-keeper = callPackage ./pkgs/servers/monitoring/perpetual-pools-keeper { };
  perpetual-pools-client = callPackage ./pkgs/servers/web-apps/perpetual-pools-client { };
  pong-client = callPackage ./pkgs/servers/web-apps/perpetual-pools-client {
    pongified = true;
  };

  # PipeWire
  pipewire = darwin.apple_sdk_11_0.callPackage ./pkgs/development/libraries/pipewire {
    # ffmpeg depends on SDL2 which depends on pipewire by default.
    # Break the cycle by disabling pipewire support in our ffmpeg.
    ffmpeg = ffmpeg.override {
      SDL2 = SDL2.override {
        pipewireSupport = false;
      };
    };
    epoll-shim = epoll-shim-hook;
    withValgrind = false;
  };

  # UxPlay
  uxplay = callPackage ./pkgs/servers/uxplay/default.nix { };

  # Wayland
  inherit epoll-shim epoll-shim-hook wayland wayland-scanner wayland-protocols;
  havoc = callPackage ./pkgs/applications/terminal-emulators/havoc {
    inherit wayland wayland-protocols;
    epoll-shim = epoll-shim-hook;
  };
  owl-compositor = callPackage ./pkgs/servers/wayland/owl-compositor {
    inherit wayland;
    inherit (buildPackages.darwin) bootstrap_cmds;
    inherit (darwin.apple_sdk.frameworks) Cocoa;
  };
  wl-clipboard = callPackage ./pkgs/tools/wayland/wl-clipboard {
    inherit wayland wayland-scanner wayland-protocols;
  };

  # WebKitGTK
  webkitgtk = darwin.apple_sdk_11_0.callPackage ./pkgs/development/libraries/webkitgtk {
    harfbuzz = harfbuzzFull;
    inherit (gst_all_1) gst-plugins-base gst-plugins-bad;
    inherit (darwin) apple_sdk;
  };

  # Misc
  freefilesync = callPackage ./pkgs/applications/networking/freefilesync { };
  mpvpaper = callPackage ./pkgs/applications/graphics/mpvpaper/default.nix { };

} // (with pkgs.python3Packages; {

  inherit eigenpy pinocchio;
  inherit pyngrok meshcat;
  example-robot-data = callPackage ./pkgs/development/python-modules/example-robot-data {
    inherit eigenpy pinocchio;
  };

}) // (with pkgs.ocaml-ng.ocamlPackages_latest; {

  heptagon = callPackage ./pkgs/development/compilers/heptagon { };
  lustre-v6 = callPackage ./pkgs/development/ocaml-modules/lustre-v6 { };

}) // pkgs.lib.optionalAttrs (pkgs.stdenv.isAarch64 && pkgs.stdenv.isLinux) {
  # Pinephone
  eg25-manager = pkgs.callPackage ./pkgs/applications/networking/eg25-manager { };
  linux_pinephone = pkgs.callPackage ./pkgs/os-specific/linux/kernel/linux-pinephone.nix { };
  pinephone-firmware = pkgs.callPackage ./pkgs/os-specific/linux/firmware/pinephone-firmware { };
}

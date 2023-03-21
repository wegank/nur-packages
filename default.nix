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
  # Jupyter Lab
  anyio = python3Packages.anyio.overrideAttrs (old: {
    doCheck = !(stdenv.isDarwin && stdenv.isAarch64);
  });

  # Misc
  flexdock = callPackage ./pkgs/applications/science/math/flexdock { };
  jgoodies-looks = callPackage ./pkgs/applications/science/math/jgoodies-looks { };
  jgraphx = callPackage ./pkgs/applications/science/math/jgraphx { };
  skinlf = callPackage ./pkgs/applications/science/math/skinlf { };

  # Wayland
  epoll-shim = callPackage ./pkgs/development/libraries/epoll-shim { };
  epoll-shim-hook = epoll-shim.override {
    itimerspecHook = true;
    atomicCloseOnExecHook = true;
  };
  wayland = callPackage ./pkgs/development/libraries/wayland {
    epoll-shim = epoll-shim-hook;
  };
  wayland-scanner = wayland.bin;
  wayland-protocols = callPackage ./pkgs/development/libraries/wayland/protocols.nix {
    inherit wayland wayland-scanner;
  };
in
{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Perpetual Pools
  # perpetual-pools-keeper = callPackage ./pkgs/servers/monitoring/perpetual-pools-keeper { };
  # perpetual-pools-client = callPackage ./pkgs/servers/web-apps/perpetual-pools-client { };
  # pong-client = callPackage ./pkgs/servers/web-apps/perpetual-pools-client {
  #   pongified = true;
  # };

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
    inherit (darwin) DarwinTools bootstrap_cmds;
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
  mpvpaper = callPackage ./pkgs/applications/graphics/mpvpaper { };
  inherit flexdock jgoodies-looks jgraphx skinlf;

} // (with pkgs.ocaml-ng.ocamlPackages_latest; {

  bdd = callPackage ./pkgs/development/ocaml-modules/bdd { };

}) // pkgs.lib.optionalAttrs (pkgs.stdenv.isAarch64 && pkgs.stdenv.isLinux) {
  # Pinephone
  eg25-manager = pkgs.callPackage ./pkgs/applications/networking/eg25-manager { };
  linux_pinephone = pkgs.callPackage ./pkgs/os-specific/linux/kernel/linux-pinephone.nix { };
  pinephone-firmware = pkgs.callPackage ./pkgs/os-specific/linux/firmware/pinephone-firmware { };
}

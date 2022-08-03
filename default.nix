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
  # PulseAudio
  pulseaudio = callPackage ./pkgs/servers/pulseaudio {
    inherit (darwin.apple_sdk.frameworks) CoreServices AudioUnit Cocoa CoreAudio;
  };
  libpulseaudio = pulseaudio.override {
    libOnly = true;
  };
  libcanberra = callPackage ./pkgs/development/libraries/libcanberra {
    inherit (darwin.apple_sdk.frameworks) Carbon CoreServices AppKit;
    inherit libpulseaudio;
  };
  # Wayland
  epoll-shim = callPackage ./pkgs/development/libraries/epoll-shim { };
  wayland = darwin.apple_sdk_11_0.callPackage ./pkgs/development/libraries/wayland {
    inherit epoll-shim;
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

  # PipeWire
  pipewire = darwin.apple_sdk_11_0.callPackage ./pkgs/development/libraries/pipewire {
    # ffmpeg depends on SDL2 which depends on pipewire by default.
    # Break the cycle by disabling pipewire support in our ffmpeg.
    ffmpeg = ffmpeg.override {
      SDL2 = SDL2.override {
        pipewireSupport = false;
      };
    };
    roc-toolkit = callPackage ./pkgs/development/libraries/audio/roc-toolkit {
      inherit libpulseaudio;
      ragel = (callPackages ./pkgs/development/tools/parsing/ragel {
        tex = texlive.combined.scheme-small;
      }).ragelStable;
    };
    inherit epoll-shim libcanberra libpulseaudio;
    withValgrind = false;
  };

  # PulseAudio
  inherit libcanberra libpulseaudio pulseaudio;
  libcanberra-gtk2 = libcanberra.override {
    gtkSupport = "gtk2";
  };
  libcanberra-gtk3 = libcanberra.override {
    gtkSupport = "gtk3";
  };
  gsound = callPackage ./pkgs/development/libraries/gsound {
    inherit libcanberra;
  };
  gtk-vnc = callPackage ./pkgs/tools/admin/gtk-vnc {
    inherit libpulseaudio;
  };

  # UxPlay
  a52dec = callPackage ./pkgs/development/libraries/a52dec { };
  uxplay = callPackage ./pkgs/servers/uxplay/default.nix {
    a52dec = callPackage ./pkgs/development/libraries/a52dec { };
  };

  # Wayland
  inherit epoll-shim wayland wayland-scanner wayland-protocols;
  havoc = callPackage ./pkgs/applications/terminal-emulators/havoc {
    inherit wayland wayland-protocols epoll-shim;
  };
  owl-compositor = callPackage ./pkgs/servers/wayland/owl-compositor {
    inherit wayland;
    inherit (buildPackages.darwin) bootstrap_cmds;
    inherit (darwin.apple_sdk.frameworks) Cocoa;
  };
  wl-clipboard = callPackage ./pkgs/tools/wayland/wl-clipboard {
    inherit wayland wayland-scanner wayland-protocols;
  };

  # Misc
  mpvpaper = callPackage ./pkgs/applications/graphics/mpvpaper/default.nix { };

} // pkgs.lib.optionalAttrs (pkgs.stdenv.isAarch64 && pkgs.stdenv.isLinux) {
  # Pinephone
  eg25-manager = pkgs.callPackage ./pkgs/applications/networking/eg25-manager { };
  linux_pinephone = pkgs.callPackage ./pkgs/os-specific/linux/kernel/linux-pinephone.nix { };
  pinephone-firmware = pkgs.callPackage ./pkgs/os-specific/linux/firmware/pinephone-firmware { };
}

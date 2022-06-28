{ lib
, config
, stdenv
, fetchFromGitHub
, fetchurl
, fetchzip
, boost
, cmake
, ffmpeg
, ffms
, fftw
, fontconfig
, freetype
, icu
, intltool
, libGL
, libGLU
, libX11
, libass
, libiconv
, luajit
, meson
, ninja
, pkg-config
, python3
, readline
, rsync
, which
, wxGTK
, zlib

, CoreText
, CoreFoundation
, AppKit
, Carbon
, IOKit
, Cocoa

, alsaSupport ? stdenv.isLinux
, alsa-lib ? null

, openalSupport ? false
, openal ? null

, pulseaudioSupport ? config.pulseaudio or stdenv.isLinux
, libpulseaudio ? null

, portaudioSupport ? false
, portaudio ? null

, spellcheckSupport ? true
, hunspell ? null

, encodingdetectSupport ? true
, libuchardet ? null
}:

assert alsaSupport -> (alsa-lib != null);
assert openalSupport -> (openal != null);
assert pulseaudioSupport -> (libpulseaudio != null);
assert portaudioSupport -> (portaudio != null);
assert spellcheckSupport -> (hunspell != null);
assert encodingdetectSupport -> (libuchardet != null);

let
  luajit52 = luajit.override { enable52Compat = true; };
  inherit (lib) optional;
in
stdenv.mkDerivation rec {
  pname = "aegisub";
  version = "3.2.2";

  src = fetchFromGitHub {
    owner = "TypesettingTools";
    repo = "Aegisub";
    name = pname;
    rev = "4776ca9dd108f65003e55a03ef60e0dd50cae7f1";
    sha256 = "sha256-KTKKzP80nON7P6JFeYxugbwX03c3muZQQrjBClQnjYE=";
  };

  googletest = fetchFromGitHub {
    owner = "google";
    repo = "googletest";
    name = "googletest";
    rev = "release-1.8.1";
    sha256 = "sha256-87sEny283oZbuaFfxNishy6uJylXYtwJfK8ea6Su4Ag=";
  };

  googletest_patch = fetchzip {
    url = "https://wrapdb.mesonbuild.com/v1/projects/gtest/1.8.1/1/get_zip#.zip";
    name = "googletest-patch";
    sha256 = "sha256-dz/lDF5F+bHSmc5mYq3ITERgFVuXbrD1ZZF6jR+H0/o=";
  };

  git_version = fetchurl {
    url = "https://sources.debian.org/data/main/a/aegisub/3.2.2%2Bdfsg-6/build/git_version.h";
    sha256 = "sha256-YstQ8TQqrlCy5EU7tiSmDoNAy7OHAb2LHrtecmbE6yU=";
  };

  nativeBuildInputs = [
    intltool
    rsync
    pkg-config
    meson
    ninja
    cmake
  ];

  buildInputs = [
    boost
    ffmpeg
    ffms
    fftw
    fontconfig
    freetype
    icu
    libGL
    libGLU
    libX11
    libass
    libiconv
    luajit52
    python3
    readline
    wxGTK
    zlib
  ]
  ++ lib.optionals stdenv.isDarwin [
    CoreText
    CoreFoundation
    AppKit
    Carbon
    IOKit
    Cocoa
  ]
  ++ optional alsaSupport alsa-lib
  ++ optional openalSupport openal
  ++ optional portaudioSupport portaudio
  ++ optional pulseaudioSupport libpulseaudio
  ++ optional spellcheckSupport hunspell
  ++ optional encodingdetectSupport libuchardet
  ;

  prePatch = ''
    rsync -a ${googletest}/ subprojects/googletest-release-1.8.1
    rsync -a ${googletest_patch}/ subprojects/googletest-release-1.8.1
    mkdir -p build && cp ${git_version} build/git_version.h
  '' + lib.optionalString stdenv.isLinux ''
    substituteInPlace meson.build --replace "get_variable(" "get_variable(pkgconfig : "
    substituteInPlace src/libresrc/meson.build --replace "command: [respack" "command: ['../tools/respack.py'"
    chmod +x tools/respack.py
    patchShebangs tools/respack.py
  '' + lib.optionalString stdenv.isDarwin ''
    sed -i "41i#include <vector>" src/audio_player.cpp
    substituteInPlace src/audio_player.cpp --replace "const factory factories[]" "const std::vector<factory> factories"
  '';

  mesonFlags = (lib.mapAttrsToList
    (option: enable: "-D${option}=${if enable then "enabled" else "disabled"}")
    {
      alsa = alsaSupport;
      openal = openalSupport;
      libpulse = pulseaudioSupport;
      portaudio = portaudioSupport;
      hunspell = spellcheckSupport;
      uchardet = encodingdetectSupport;
    });

  # Meson is no longer able to pick up Boost automatically.
  # https://github.com/NixOS/nixpkgs/issues/86131
  BOOST_INCLUDEDIR = "${lib.getDev boost}/include";
  BOOST_LIBRARYDIR = "${lib.getLib boost}/lib";

  enableParallelBuilding = true;

  hardeningDisable = [
    "bindnow"
    "relro"
  ];

  meta = with lib; {
    homepage = "https://github.com/Aegisub/Aegisub";
    description = "An advanced subtitle editor";
    longDescription = ''
      Aegisub is a free, cross-platform open source tool for creating and
      modifying subtitles. Aegisub makes it quick and easy to time subtitles to
      audio, and features many powerful tools for styling them, including a
      built-in real-time video preview.
    '';
    # The Aegisub sources are itself BSD/ISC, but they are linked against GPL'd
    # softwares - so the resulting program will be GPL
    license = licenses.bsd3;
    # maintainers = [ maintainers.AndersonTorres ];
    platforms = platforms.unix;
  };
}

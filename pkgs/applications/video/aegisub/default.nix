{ lib
, config
, stdenv
, fetchgit
, autoreconfHook
, boost
, cmake
, expat
, harfbuzz
, ffmpeg
, ffms
, fftw
, fontconfig
, freetype
, fribidi
, glib
, icu
, intltool
, libGL
, libGLU
, libX11
, libass
, libiconv
, libuchardet
, pcre
, pkg-config
, runCommand
, which
, wxGTK
, zlib

, CoreText
, CoreFoundation
, AppKit
, Carbon
, IOKit
, Cocoa

, spellcheckSupport ? true
, hunspell ? null

, automationSupport ? true
, luajit ? null

, openalSupport ? false
, openal ? null

, alsaSupport ? stdenv.isLinux
, alsa-lib ? null

, pulseaudioSupport ? config.pulseaudio or stdenv.isLinux
, libpulseaudio ? null

, portaudioSupport ? false
, portaudio ? null

}:

assert spellcheckSupport -> (hunspell != null);
assert automationSupport -> (luajit != null);
assert openalSupport -> (openal != null);
assert alsaSupport -> (alsa-lib != null);
assert pulseaudioSupport -> (libpulseaudio != null);
assert portaudioSupport -> (portaudio != null);

let
  luajit52 = luajit.override { enable52Compat = true; };
  inherit (lib) optional;
in
stdenv.mkDerivation rec {
  pname = "aegisub";
  version = "3.3.2";

  src = fetchgit {
    url = "https://github.com/wangqr/${pname}.git";
    rev = "91f8b5f91eb960bad19899c10af08aca34f9b697";
    sha256 = "sha256-PlAqRSh1EoayJ6F6VxV+d+f7B/XmYWEHQnhpO70m1MA=";
    postFetch = ''
      substituteInPlace $out/CMakeLists.txt \
        --replace "luajit)" "luajit-5.1)" \
        --replace "luajit " "luajit-5.1 " \
        --replace "luajit-minilua" "luajit"
      substituteInPlace $out/vendor/luabins/CMakeLists.txt \
        --replace "luajit)" "luajit-5.1)"
      sed -i '16,218d' $out/CMakeLists.txt
      sed -i '16iinclude_directories(${luajit}/include)' $out/CMakeLists.txt
      sed -i '17ilink_directories(${luajit}/lib)' $out/CMakeLists.txt
    '';
  };

  nativeBuildInputs = [
    intltool
    luajit52
    pkg-config
    which
    cmake
  ];

  buildInputs = [
    boost
    expat
    ffmpeg
    ffms
    fftw
    fontconfig
    freetype
    fribidi
    glib
    harfbuzz
    icu
    libGL
    libGLU
    libX11
    libass
    libiconv
    libuchardet
    pcre
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
  ++ optional automationSupport luajit52
  ++ optional openalSupport openal
  ++ optional portaudioSupport portaudio
  ++ optional pulseaudioSupport libpulseaudio
  ++ optional spellcheckSupport hunspell
  ;

  configurePhase = "
    export FORCE_GIT_VERSION=${version}
    mkdir build-dir
    cd build-dir
    cmake -DCMAKE_INSTALL_PREFIX=$out ..
  ";

  enableParallelBuilding = true;

  hardeningDisable = [
    "bindnow"
    "relro"
  ];

  meta = with lib; {
    homepage = "https://github.com/wangqr/Aegisub";
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
    maintainers = [ maintainers.AndersonTorres ];
    platforms = platforms.unix;
  };
}

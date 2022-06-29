{ lib
, config
, stdenv
, fetchFromGitHub
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
, luajit
, luajitPackages
, pcre
, pkg-config
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

, openalSupport ? false
, openal ? null

, alsaSupport ? stdenv.isLinux
, alsa-lib ? null

, pulseaudioSupport ? config.pulseaudio or stdenv.isLinux
, libpulseaudio ? null

, portaudioSupport ? false
, portaudio ? null

, doCheck ? false
}:

assert spellcheckSupport -> (hunspell != null);
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

  src = fetchFromGitHub {
    owner = "wangqr";
    repo = pname;
    rev = "91f8b5f91eb960bad19899c10af08aca34f9b697";
    sha256 = "sha256-lPkPWSsncsBKJHDnma9cUXsQJynruT9JpPkMTHdQ/e8=";
  };

  nativeBuildInputs = [
    intltool
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
    luajit52
    pcre
    wxGTK
    zlib
  ]
  ++ lib.optionals doCheck (with luajitPackages; [
    busted
    luarocks
    (callPackage ./uuid.nix { lua = luajit; })
  ])
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
  ;

  enableParallelBuilding = true;

  hardeningDisable = [
    "bindnow"
    "relro"
  ];

  patchPhase = ''
    substituteInPlace CMakeLists.txt \
      --replace "luajit)" "luajit-5.1)" \
      --replace "luajit " "luajit-5.1 " \
      --replace "luajit-minilua" "luajit"
    substituteInPlace CMakeLists.test.txt \
      --replace "luajit " "luajit-5.1 "
    substituteInPlace vendor/luabins/CMakeLists.txt \
      --replace "luajit)" "luajit-5.1)"
    sed -i '16,218d' CMakeLists.txt
    sed -i '16iinclude_directories(${luajit}/include)' CMakeLists.txt
    sed -i '17ilink_directories(${luajit}/lib)' CMakeLists.txt
  '';

  configurePhase = ''
    export FORCE_GIT_VERSION=${version}
    mkdir build-dir
    cd build-dir
    cmake -DCMAKE_INSTALL_PREFIX=$out -DWITH_TEST=${lib.boolToString doCheck} ..
  '';

  inherit doCheck;

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

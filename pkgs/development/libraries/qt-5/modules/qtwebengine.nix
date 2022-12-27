{ lib
, stdenv
, qt5
, MediaPlayer
, MediaAccessibility
, SecurityInterface
, Vision
, CoreML
, ...
}:

qt5.qtwebengine.overrideAttrs (old: {
  postPatch = old.postPatch
    # ld: library not found for -lpmenergy
    + lib.optionalString stdenv.isDarwin ''
    sed -i "/pmsample/d;/pmenergy/d" src/3rdparty/chromium/base/BUILD.gn
    sed -z -i 's|extern "C".*extern "C"||' src/3rdparty/chromium/base/process/process_metrics_mac.cc
    sed -i "/pm_sample_task/d;/pm_energy_impact/d" src/3rdparty/chromium/base/process/process_metrics_mac.cc
  ''
    # ld: fatal warning(s) induced error (-fatal_warnings)
    + lib.optionalString stdenv.isDarwin ''
    substituteInPlace src/3rdparty/chromium/build/config/compiler/BUILD.gn \
      --replace "-Wl,-fatal_warnings" ""
  '';

  NIX_CFLAGS_COMPILE = lib.optionals stdenv.cc.isGNU [
    "-Wno-class-memaccess"
  ] ++ lib.optionals (stdenv.hostPlatform.gcc.arch or "" == "sandybridge") [
    "-march=westmere"
  ] ++ lib.optionals stdenv.cc.isClang [
    "-Wno-elaborated-enum-base"
  ];

  propagatedBuildInputs = old.propagatedBuildInputs ++ lib.optionals stdenv.isDarwin [
    MediaPlayer
    MediaAccessibility
    SecurityInterface
    Vision
    CoreML
  ];

  meta.broken = stdenv.isDarwin && stdenv.isx86_64;
})

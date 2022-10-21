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
    # Set host_cpu to 'arm64' on aarch64-darwin hosts
    + lib.optionalString (stdenv.isDarwin && stdenv.isAarch64) ''
    substituteInPlace src/3rdparty/gn/tools/gn/args.cc \
      --replace "arch = kArm;" "arch = kArm64;"
  ''
    # error: functional-style cast from 'neon::F' (aka 'V<float>') to '__fp16' is not allowed
    + lib.optionalString (stdenv.isDarwin && stdenv.isAarch64) ''
    substituteInPlace src/3rdparty/chromium/third_party/skia/src/opts/SkRasterPipeline_opts.h \
      --replace "!defined(SK_BUILD_FOR_GOOGLE3)" "0"
  ''
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
})

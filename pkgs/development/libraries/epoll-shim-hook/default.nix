{ lib
, stdenv
, epoll-shim
, writeText
, itimerspecHook ? false
, atomicCloseOnExecHook ? false
}:

let
  hook = itimerspecHook || atomicCloseOnExecHook;
  atomicFeatures = [ "socket" "socketpair" "pipe2" ];
in
epoll-shim.overrideAttrs (old: {
  postPatch = lib.optionalString hook ''
    sed -i '1s/hidden/default/;2s/1/0/' src/CMakeLists.txt
  '' + lib.optionalString atomicCloseOnExecHook (lib.concatMapStrings
    (feature: ''
      sed -i '118i''$<BUILD_INTERFACE:compat_enable_${feature}>' src/CMakeLists.txt
    '')
    atomicFeatures
  );

  postInstall = lib.optionalString hook ''
    cp $src/src/compat_*.h $out/include/
  '';

  setupHook =
    if !hook then null else
    let
      enableFeature = feature: ''
        export NIX_CFLAGS_COMPILE+=" -D COMPAT_ENABLE_${lib.toUpper feature} -include compat_${feature}.h"
      '';
    in
    (writeText "setup-hook" (''
      export NIX_CFLAGS_COMPILE+=" -I$1/include/libepoll-shim"
      export NIX_LDFLAGS+=" -L$1/lib -lepoll-shim"
    ''
    + lib.optionalString itimerspecHook (enableFeature "itimerspec")
    + lib.optionalString atomicCloseOnExecHook (''
      export NIX_CFLAGS_COMPILE+=" -D O_CLOEXEC=0x1000000"
    '' + lib.concatMapStrings enableFeature atomicFeatures
    )));
})

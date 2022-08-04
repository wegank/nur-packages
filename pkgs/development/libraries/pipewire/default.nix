{ stdenv
, lib
, buildPackages
, fetchFromGitLab
, removeReferencesTo
, python3
, meson
, ninja
, eudev
, systemd
, enableSystemd ? stdenv.isLinux
, enableUdev ? stdenv.isLinux && !enableSystemd
, pkg-config
, docutils
, doxygen
, graphviz
, glib
, dbus
, alsa-lib
, libjack2
, libusb1
, udev
, libva
, libsndfile
, vulkan-headers
, vulkan-loader
, webrtc-audio-processing
, ncurses
, readline81 # meson can't find <7 as those versions don't have a .pc file
, lilv
, makeFontsConf
, callPackage
, nixosTests
, withValgrind ? lib.meta.availableOn stdenv.hostPlatform valgrind
, valgrind
, withMediaSession ? true
, alsaSupport ? stdenv.isLinux
, v4l2Support ? stdenv.isLinux
, libcameraSupport ? stdenv.isLinux
, libcamera
, libdrm
, gstreamerSupport ? true
, gst_all_1
, ffmpegSupport ? true
, ffmpeg
, bluezSupport ? stdenv.isLinux
, bluez
, sbc
, libfreeaptx
, ldacbt
, fdk_aac
, nativeHspSupport ? true
, nativeHfpSupport ? true
, ofonoSupport ? true
, hsphfpdSupport ? true
, pulseTunnelSupport ? true
, libpulseaudio
, zeroconfSupport ? true
, avahi
, raopSupport ? true
, openssl
, rocSupport ? true
, roc-toolkit
, x11Support ? true
, libcanberra
, xorg
, avbSupport ? stdenv.isLinux
, epoll-shim
, libinotify-kqueue
}:

let
  mesonEnableFeature = b: if b then "enabled" else "disabled";
  mesonList = l: "[" + lib.concatStringsSep "," l + "]";

  self = stdenv.mkDerivation rec {
    pname = "pipewire";
    version = "0.3.56";

    outputs = [
      "out"
      "lib"
      "pulse"
      "jack"
      "dev"
      "doc"
      "man"
      "installedTests"
    ];

    src = fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "pipewire";
      repo = "pipewire";
      rev = version;
      sha256 = "sha256-wbHHr7BW8Gdj9D1IjzOuD6VuXApJ5E0Zde2iKWImzxg=";
    };

    patches = [
      # Break up a dependency cycle between outputs.
      ./0040-alsa-profiles-use-libdir.patch
      # Change the path of the pipewire-pulse binary in the service definition.
      ./0050-pipewire-pulse-path.patch
      # Move installed tests into their own output.
      ./0070-installed-tests-path.patch
      # Add option for changing the config install directory
      ./0080-pipewire-config-dir.patch
      # Remove output paths from the comments in the config templates to break dependency cycles
      ./0090-pipewire-config-template-paths.patch
      # Place SPA data files in lib output to avoid dependency cycles
      ./0095-spa-data-dir.patch
    ];

    nativeBuildInputs = [
      docutils
      doxygen
      graphviz
      meson
      ninja
      pkg-config
      python3
    ];

    buildInputs = [
      dbus
      glib
      libjack2
      libusb1
      libsndfile
      lilv
      ncurses
      readline81
      vulkan-headers
      vulkan-loader
      webrtc-audio-processing
    ]
    ++ lib.optionals enableSystemd [ systemd udev ]
    ++ lib.optional enableUdev eudev
    ++ lib.optional alsaSupport alsa-lib
    ++ lib.optionals gstreamerSupport [ gst_all_1.gst-plugins-base gst_all_1.gstreamer ]
    ++ lib.optionals libcameraSupport [ libcamera libdrm ]
    ++ lib.optional ffmpegSupport ffmpeg
    ++ lib.optionals bluezSupport [ bluez libfreeaptx ldacbt sbc fdk_aac ]
    ++ lib.optional pulseTunnelSupport libpulseaudio
    ++ lib.optional zeroconfSupport avahi
    ++ lib.optional raopSupport openssl
    ++ lib.optional rocSupport roc-toolkit
    ++ lib.optionals x11Support [ libcanberra xorg.libX11 xorg.libXfixes ]
    ++ lib.optional stdenv.isDarwin [ epoll-shim libinotify-kqueue ];

    # Valgrind binary is required for running one optional test.
    checkInputs = lib.optional withValgrind valgrind;

    mesonFlags = [
      "-Ddocs=enabled"
      "-Dtests=${mesonEnableFeature doCheck}"
      "-Dinstalled_tests=enabled"
      "-Dinstalled_test_prefix=${placeholder "installedTests"}"
      "-Dpipewire_pulse_prefix=${placeholder "pulse"}"
      "-Dlibjack-path=${placeholder "jack"}/lib"
      "-Dalsa=${mesonEnableFeature alsaSupport}"
      "-Dpipewire-alsa=${mesonEnableFeature alsaSupport}"
      "-Dv4l2=${mesonEnableFeature v4l2Support}"
      "-Dpipewire-v4l2=${mesonEnableFeature v4l2Support}"
      "-Dlibv4l2-path=${placeholder "out"}/lib"
      "-Dlibcamera=${mesonEnableFeature libcameraSupport}"
      "-Droc=${mesonEnableFeature rocSupport}"
      "-Dlibpulse=${mesonEnableFeature pulseTunnelSupport}"
      "-Davahi=${mesonEnableFeature zeroconfSupport}"
      "-Dgstreamer=${mesonEnableFeature gstreamerSupport}"
      "-Dsystemd=${mesonEnableFeature enableSystemd}"
      "-Dsystemd-system-service=${mesonEnableFeature enableSystemd}"
      "-Dudev=${mesonEnableFeature enableUdev}"
      "-Dudevrulesdir=${placeholder "out"}/lib/udev/rules.d"
      "-Dffmpeg=${mesonEnableFeature ffmpegSupport}"
      "-Dbluez5=${mesonEnableFeature bluezSupport}"
      "-Dbluez5-backend-hsp-native=${mesonEnableFeature nativeHspSupport}"
      "-Dbluez5-backend-hfp-native=${mesonEnableFeature nativeHfpSupport}"
      "-Dbluez5-backend-ofono=${mesonEnableFeature ofonoSupport}"
      "-Dbluez5-backend-hsphfpd=${mesonEnableFeature hsphfpdSupport}"
      "-Dbluez5-codec-lc3plus=disabled"
      "-Dsysconfdir=/etc"
      "-Dpipewire_confdata_dir=${placeholder "lib"}/share/pipewire"
      "-Draop=${mesonEnableFeature raopSupport}"
      "-Dsession-managers="
      "-Dvulkan=enabled"
      "-Dx11=${mesonEnableFeature x11Support}"
      "-Dx11-xfixes=${mesonEnableFeature x11Support}"
      "-Dlibcanberra=${mesonEnableFeature x11Support}"
      "-Dsdl2=disabled" # required only to build examples, causes dependency loop
      "-Davb=${mesonEnableFeature avbSupport}"
    ];

    # Fontconfig error: Cannot load default config file
    FONTCONFIG_FILE = makeFontsConf { fontDirectories = [ ]; };

    doCheck = stdenv.isLinux;

    postUnpack = ''
      patchShebangs source/doc/input-filter.sh
      patchShebangs source/doc/input-filter-h.sh
    '';

    postPatch = lib.optionals stdenv.isDarwin ''
      # pretend to be MidnightBSD
      find . -type f -exec sed -i 's/__MidnightBSD__/__APPLE__/g' {} +
      find . -type f -exec sed -i 's/midnightbsd/darwin/g' {} +
      sed -i 's/#elif defined(__FreeBSD__) || defined(__APPLE__)/#elif defined(__FreeBSD__)/g' src/pipewire/mem.c
      sed -i 's/#elif defined(__FreeBSD__) || defined(__APPLE__)/#elif defined(__FreeBSD__)/g' src/modules/module-rt.c
      sed -i 's/#if defined(__FreeBSD__) || defined(__APPLE__)/#if defined(__FreeBSD__)/g' src/modules/module-rt.c
      sed -i 's/#if defined(__FreeBSD__) || defined(__APPLE__)/#if defined(__FreeBSD__)/g' src/pipewire/thread.c
      sed -i 's/#ifndef __FreeBSD__/#ifndef __APPLE__/g' spa/plugins/support/cpu.c

      # patch test linkers
      find . -type f -exec sed -i 's/pwtest_suite_section/pwtest_section/g' {} +
      find . -type f -exec sed -i 's/section("pwtest_section")/section("__RODATA,pwtest_section")/g' {} +
      substituteInPlace test/pwtest.c \
        --replace 'pwtest_suite_decl __start_pwtest_section' 'pwtest_suite_decl __start_pwtest_section __asm("section$start$__RODATA$pwtest_section")' \
        --replace 'pwtest_suite_decl __stop_pwtest_section' 'pwtest_suite_decl __stop_pwtest_section __asm("section$end$__RODATA$pwtest_section")' \

      # patch src linkers
      find . -type f -exec sed -i 's/pw_mod_pulse_modules/pw_modules/g' {} +
      find . -type f -exec sed -i 's/section("pw_modules")/section("__RODATA,pw_modules")/g' {} +
      substituteInPlace src/modules/module-protocol-pulse/module.c \
        --replace '__start_pw_modules[]' '__start_pw_modules[] __asm("section$start$__RODATA$pw_modules")' \
        --replace '__stop_pw_modules[]' '__stop_pw_modules[] __asm("section$end$__RODATA$pw_modules")' \

      # replace <locale.h> with <xlocale.h>
      sed -i 's/<locale.h>/<xlocale.h>/g' spa/include/spa/utils/string.h

      # replace <sys/endian.h> with <libkern/OSByteOrder.h>
      substituteInPlace spa/plugins/audioconvert/fmt-ops.h \
        --replace "#include <sys/endian.h>" "#include <libkern/OSByteOrder.h>" \
        --replace "bswap16" "OSSwapInt16" --replace "bswap32" "OSSwapInt32" --replace "bswap64" "OSSwapInt64"

      # implement gettid
      substituteInPlace src/modules/module-rt.c \
        --replace "#error \"No gettid impl\"" "syscall(SYS_thread_selfid);"

      # FIXME: patch accept4
      substituteInPlace src/modules/module-protocol-native.c \
        --replace "accept4(fd, (struct sockaddr *) &name, &length, SOCK_CLOEXEC)" "accept(fd, (struct sockaddr *) &name, &length)"
      substituteInPlace src/modules/module-protocol-pulse/server.c \
        --replace "accept4(fd, (struct sockaddr *) &name, &length, SOCK_CLOEXEC)" "accept(fd, (struct sockaddr *) &name, &length)"
      substituteInPlace src/modules/module-protocol-simple.c \
        --replace "accept4(fd, &addr, &addrlen, SOCK_NONBLOCK | SOCK_CLOEXEC)" "accept(fd, &addr, &addrlen)"
      
      # FIXME: patch pipe2
      substituteInPlace test/pwtest.c \
        --replace "pipe[2]" "fds[2]" \
        --replace "pipe2(pipe, O_CLOEXEC | O_NONBLOCK)" "pipe(fds)" \
        --replace "pipe[0]" "fds[0]" \
        --replace "pipe[1]" "fds[1]" \

      # FIXME: patch socket constants
      find . -type f -exec sed -i 's/SOCK_CLOEXEC/0/g' {} +
      find . -type f -exec sed -i 's/SOCK_NONBLOCK/0/g' {} +
      find . -type f -exec sed -i 's/MSG_CMSG_CLOEXEC/0/g' {} +

      # FIXME: misc
      find . -type f -exec sed -i 's/__attribute__((retain))//g' {} +
      substituteInPlace spa/tests/stress-ringbuffer.c \
        --replace "sem_timedwait(&sem, &ts)" "sem_wait(&sem)"
      substituteInPlace src/pipewire/thread.c \
        --replace "pthread_setname_np(pt, str)" "0"
      substituteInPlace src/pipewire/thread-loop.c \
        --replace "CHECK(pthread_condattr_setclock(&cattr, CLOCK_REALTIME), clean_lock);" ""
    '';

    postInstall = ''
      mkdir $out/nix-support
      ${if (stdenv.hostPlatform == stdenv.buildPlatform) then ''
        pushd $lib/share/pipewire
        for f in *.conf; do
          echo "Generating JSON from $f"

          $out/bin/spa-json-dump "$f" > "$out/nix-support/$f.json"
        done
        popd
      '' else ''
        cp ${buildPackages.pipewire}/nix-support/*.json "$out/nix-support"
      ''}

      ${lib.optionalString enableSystemd ''
        moveToOutput "share/systemd/user/pipewire-pulse.*" "$pulse"
        moveToOutput "lib/systemd/user/pipewire-pulse.*" "$pulse"
      ''}

      moveToOutput "bin/pipewire-pulse" "$pulse"

      moveToOutput "bin/pw-jack" "$jack"
    '';

    passthru = {
      updateScript = ./update-pipewire.sh;
      tests = {
        installedTests = nixosTests.installed-tests.pipewire;

        # This ensures that all the paths used by the NixOS module are found.
        test-paths = callPackage ./test-paths.nix { package = self; } {
          paths-out = [
            "share/alsa/alsa.conf.d/50-pipewire.conf"
            "nix-support/client-rt.conf.json"
            "nix-support/client.conf.json"
            "nix-support/jack.conf.json"
            "nix-support/minimal.conf.json"
            "nix-support/pipewire.conf.json"
            "nix-support/pipewire-pulse.conf.json"
          ];
          paths-lib = [
            "lib/alsa-lib/libasound_module_pcm_pipewire.so"
            "share/alsa-card-profile/mixer"
          ];
        };
      };
    };

    meta = with lib; {
      description = "Server and user space API to deal with multimedia pipelines";
      homepage = "https://pipewire.org/";
      license = licenses.mit;
      platforms = platforms.unix;
      maintainers = with maintainers; [ jtojnar kranzes ];
    };
  };

in
self

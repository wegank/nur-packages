{ lib
, gcc12Stdenv
, fetchFromGitHub
, fetchpatch
, pkg-config
, curl
, glib
, gtk3
, libssh2
, openssl
, wxGTK31-gtk3
, wxGTK31-gtk3-override ? null
}:

let
  wxGTK316-gtk3 = wxGTK31-gtk3.overrideAttrs (old: rec {
    version = "3.1.6";
    src = fetchFromGitHub {
      owner = "wxWidgets";
      repo = "wxWidgets";
      rev = "v${version}";
      hash = "sha256-8dIItdu8cyYhPGbPuQ3hVsuZR5DA1wPydRaHcBJCHZw=";
      fetchSubmodules = true;
    };
  });
  wxGTK31-gtk3-override' = if wxGTK31-gtk3-override == null then wxGTK316-gtk3 else wxGTK31-gtk3-override;
in
gcc12Stdenv.mkDerivation rec {
  pname = "freefilesync";
  version = "11.25";

  src = fetchFromGitHub {
    owner = "hkneptune";
    repo = "FreeFileSync";
    rev = "v${version}";
    sha256 = "sha256-JV9qwBiF9kl+wc9+7lUufQVu6uiMQ6vojntxduNJ8MI=";
  };

  patches = [
    # Patches from ROSA Linux
    (fetchpatch {
      url = "https://abf.io/import/freefilesync/raw/rosa2021.1-11.25-1/ffs_devuan.patch";
      sha256 = "sha256-2zSmlBSSDHrU8Csts5Gm6dYaKbPEWC9+Nz3SFTBEpvk=";
      postFetch = ''
        sed -i "1,12d;s/ for Rosa//" $out
      '';
    })
    (fetchpatch {
      url = "https://abf.io/import/freefilesync/raw/rosa2021.1-11.25-1/ffs_devuan_gtk3.patch";
      sha256 = "sha256-NXt/+BRTcMk8bnjR9Hipv1NzV9YqRJqy0e3RMInoWsA=";
      postFetch = ''
        substituteInPlace $out --replace "-isystem/usr/include/gtk-3.0" ""
      '';
    })
    (fetchpatch {
      url = "https://abf.io/import/freefilesync/raw/rosa2021.1-11.25-1/ffs_sftp.patch";
      sha256 = "sha256-tOIBIUgeTmOwNfrFFXUWu/7eXPHd9qdmqMHQ3ctvIpQ=";
    })
  ];

  postPatch = ''
    substituteInPlace FreeFileSync/Source/ui/version_check.cpp \
      --replace "openBrowserForDownload();" "openBrowserForDownload(parent);"
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    curl
    glib
    gtk3
    libssh2
    openssl
    wxGTK31-gtk3-override'
  ];

  NIX_CFLAGS_COMPILE = [
    # Undef g_object_ref on GLib 2.56+
    "-DGLIB_VERSION_MIN_REQUIRED=GLIB_VERSION_2_54"
    "-DGLIB_VERSION_MAX_ALLOWED=GLIB_VERSION_2_54"
  ];

  buildPhase = ''
    runHook preBuild

    chmod +w FreeFileSync/Build
    cd FreeFileSync/Source
    make
    cd RealTimeSync
    make
    cd ../../..

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -R FreeFileSync/Build/* $out
    mv $out/{Bin,bin}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Open Source File Synchronization & Backup Software";
    homepage = "https://freefilesync.org";
    platforms = platforms.linux;
    broken = !gcc12Stdenv.isLinux;
    maintainers = with maintainers; [ wegank ];
  };
}

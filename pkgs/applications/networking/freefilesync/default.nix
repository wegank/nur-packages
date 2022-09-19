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
}:

let
  stdenv = gcc12Stdenv;
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
in
stdenv.mkDerivation rec {
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
      sha256 = "sha256-o8T/tBinlhM1I82yXxm0ogZcZf+uri95vTJrca5mcqs=";
      excludes = [ "FreeFileSync/Source/ffs_paths.cpp" ];
      postFetch = ''
        substituteInPlace $out --replace " for Rosa" ""
      '';
    })
    (fetchpatch {
      url = "https://abf.io/import/freefilesync/raw/rosa2021.1-11.25-1/ffs_devuan_gtk3.patch";
      sha256 = "sha256-fsO3pZAjntFJCtdxsjgCTSW3QJxOr3MGlSo6azdkm/M=";
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
    wxGTK316-gtk3
  ];

  NIX_CFLAGS_COMPILE = [
    # Undef g_object_ref on GLib 2.56+
    "-DGLIB_VERSION_MIN_REQUIRED=GLIB_VERSION_2_54"
    "-DGLIB_VERSION_MAX_ALLOWED=GLIB_VERSION_2_54"
  ];

  preBuild = ''
    chmod +w FreeFileSync/Build
    cd FreeFileSync/Source
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -R ../Build/* $out
    mv $out/{Bin,bin}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Open Source File Synchronization & Backup Software";
    homepage = "https://freefilesync.org";
    platforms = platforms.linux;
    broken = !stdenv.isLinux;
    maintainers = with maintainers; [ wegank ];
  };
}

{ lib
, gcc12Stdenv
, fetchzip
, fetchpatch
, fetchFromGitHub
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

  src = fetchzip {
    url = "https://freefilesync.org/download/FreeFileSync_${version}_Source.zip";
    stripRoot = false;
    sha256 = "sha256-+PR53t5O2zrlaRgOgp0Kwjaji1PvlvhnjNeUALiBy8A=";
  };

  patches = [
    # Patches from ROSA Linux
    (fetchpatch {
      url = "https://abf.io/import/${pname}/raw/rosa2021.1-${version}-1/ffs_devuan.patch";
      excludes = [ "FreeFileSync/Source/ffs_paths.cpp" ];
      postFetch = ''substituteInPlace $out --replace " for Rosa" ""'';
      sha256 = "sha256-o8T/tBinlhM1I82yXxm0ogZcZf+uri95vTJrca5mcqs=";
    })
    (fetchpatch {
      url = "https://abf.io/import/${pname}/raw/rosa2021.1-${version}-1/ffs_devuan_gtk3.patch";
      sha256 = "sha256-fsO3pZAjntFJCtdxsjgCTSW3QJxOr3MGlSo6azdkm/M=";
    })
    (fetchpatch {
      url = "https://abf.io/import/${pname}/raw/rosa2021.1-${version}-1/ffs_openssl.patch";
      sha256 = "sha256-6BIFZIKjfp0zcaAQIrc9OEaJUf4oRgebzihf3oPnjxg=";
    })
    (fetchpatch {
      url = "https://abf.io/import/${pname}/raw/rosa2021.1-${version}-1/ffs_sftp.patch";
      sha256 = "sha256-tOIBIUgeTmOwNfrFFXUWu/7eXPHd9qdmqMHQ3ctvIpQ=";
    })
  ];

  postPatch = ''
    substituteInPlace FreeFileSync/Source/ui/version_check.cpp \
      --replace "openBrowserForDownload();" "openBrowserForDownload(parent);"
  '';

  NIX_CFLAGS_COMPILE = [
    "-DGLIB_VERSION_MIN_REQUIRED=GLIB_VERSION_2_54"
    "-DGLIB_VERSION_MAX_ALLOWED=GLIB_VERSION_2_54"
  ];

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

{ lib
, stdenv
, fetchFromGitLab
, fetchpatch
, desktop-file-utils
, meson
, ninja
, pkg-config
, rustPlatform
, wrapGAppsHook4
, glib
, gsettings-desktop-schemas
, gst_all_1
, gtk4
, libadwaita
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "snapshot";
  version = "unstable-2023-04-13";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "Incubator";
    repo = "snapshot";
    rev = "b81780b43569c264899a75b5e204c5e4df1ad1a8";
    hash = "sha256-Z4qT9LkiFv21xduKkTRTXuYCD88Gu5aiL+19KaX34CA=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit (finalAttrs) src;
    name = "${finalAttrs.pname}-${finalAttrs.version}";
    hash = "sha256-6j4ntEkvZsyqYr3VzQ4pr+htDxLWpQD2O+cO9UjL97s=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustPlatform.rust.cargo
    rustPlatform.rust.rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    gsettings-desktop-schemas
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gtk4
    libadwaita
  ];

  meta = with lib; {
    description = "Take pictures and videos";
    homepage = "https://gitlab.gnome.org/Incubator/snapshot";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ wegank ];
    platforms = platforms.linux;
    broken = stdenv.isDarwin;
  };
})

{
  lib,
  stdenv,
  fetchFromGitHub,
  paraview,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ftk";
  version = "0.0.9";

  src = fetchFromGitHub {
    owner = "hguo";
    repo = "ftk";
    rev = finalAttrs.version;
    hash = "sha256-kWp8DGeSUhfOWLK5fVaiJeaTMRy5NbhFBU+8uhxumjg=";
  };

  inherit (paraview) nativeBuildInputs preConfigure;

  buildInputs = [
    paraview
  ] ++ paraview.buildInputs;

  cmakeFlags = [
    (lib.cmakeBool "FTK_BUILD_PARAVIEW" true)
    (lib.cmakeOptionType "PATH" "CMAKE_INSTALL_BINDIR" "bin")
    (lib.cmakeOptionType "PATH" "CMAKE_INSTALL_INCLUDEDIR" "include")
    (lib.cmakeOptionType "PATH" "CMAKE_INSTALL_LIBDIR" "lib")
  ];

  meta = with lib; {
    description = "The Feature Tracking Kit";
    homepage = "https://github.com/hguo/ftk";
    licenses = licenses.mit;
    maintainers = with maintainers; [ wegank ];
    platforms = platforms.linux;
    broken = true;
  };
})

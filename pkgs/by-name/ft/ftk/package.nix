{ lib
, stdenv
, fetchFromGitHub
, cmake
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

  nativeBuildInputs = [
    cmake
  ];

  meta = with lib; {
    description = "The Feature Tracking Kit";
    homepage = "https://github.com/hguo/ftk";
    licenses = licenses.mit;
    maintainers = with maintainers; [ wegank ];
    platforms = platforms.linux;
    broken = stdenv.isDarwin;
  };
})

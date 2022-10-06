{ lib
, stdenv
, fetchFromGitHub
, cmake
, boost
, eigen
, eigenpy
, example-robot-data
, pinocchio
, urdfdom
, urdfdom-headers
}:

stdenv.mkDerivation rec {
  pname = "crocoddyl";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "loco-3d";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-IQ+8ZZXVTTRFa4uGetpylRab4P9MSTU2YtytYA3z6ys=";
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    boost
    eigen
    eigenpy
    example-robot-data
    pinocchio
    urdfdom
    urdfdom-headers
  ];

  meta = with lib; {
    description = "Crocoddyl optimal control library";
    homepage = "https://github.com/loco-3d/crocoddyl";
    license = licenses.bsd3;
    maintainers = with maintainers; [ wegank ];
  };
}

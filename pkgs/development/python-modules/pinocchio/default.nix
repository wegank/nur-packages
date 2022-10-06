{ lib
, stdenv
, fetchFromGitHub
, cmake
, boost
, eigen
, eigenpy
, urdfdom
, numpy
}:

stdenv.mkDerivation rec {
  pname = "pinocchio";
  version = "2.6.10";

  src = fetchFromGitHub {
    owner = "stack-of-tasks";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-3M0nbFlFtcYECacQ6O3znurNGt47ZNrsu+3kWNpRzDo=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace src/math/sincos.hpp --replace "__APPLE__" "0"
    sed -i '/pybind11/d' unittest/python/CMakeLists.txt
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    boost
    eigen
    eigenpy
    urdfdom
  ];

  propagatedBuildInputs = [
    numpy
  ];

  meta = with lib; {
    description = "A fast and flexible implementation of Rigid Body Dynamics algorithms and their analytical derivatives";
    homepage = "https://github.com/stack-of-tasks/pinocchio";
    license = licenses.bsd2;
    maintainers = with maintainers; [ wegank ];
  };
}

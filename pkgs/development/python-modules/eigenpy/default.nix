{ lib
, stdenv
, fetchFromGitHub
, cmake
, boost
, eigen
, numpy
}:

stdenv.mkDerivation rec {
  pname = "eigenpy";
  version = "2.7.14";

  src = fetchFromGitHub {
    owner = "stack-of-tasks";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-oUNa+YYxplqe5eh0j0ToFHeg7eh7z7YmNjRoNqG5d5k=";
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    boost
    eigen
  ];

  propagatedBuildInputs = [
    numpy
  ];

  meta = with lib; {
    description = "Bindings between Numpy and Eigen using Boost.Python";
    homepage = "https://github.com/stack-of-tasks/eigenpy";
    license = licenses.bsd2;
    maintainers = with maintainers; [ wegank ];
  };
}

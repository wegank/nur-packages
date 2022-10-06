{ lib
, stdenv
, fetchFromGitHub
, cmake
, boost
, eigen
, eigenpy
, pinocchio
, urdfdom
}:

stdenv.mkDerivation rec {
  pname = "example-robot-data";
  version = "4.0.2";

  src = fetchFromGitHub {
    owner = "Gepetto";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-QOtJo4ysfzZkZddqqncm9qzxF04wFGvuG4h7f8uQIEg=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    boost
    eigen
    eigenpy
    pinocchio
    urdfdom
  ];

  meta = with lib; {
    description = "Set of robot URDFs for benchmarking and developed examples.";
    homepage = "https://github.com/Gepetto/example-robot-data";
    license = licenses.bsd3;
    maintainers = with maintainers; [ wegank ];
  };
}

{ lib
, stdenv
, fetchgit
, cmake
, withGurobi ? false
, gurobi
, withCplex ? false
, cplex
, withLpsolve ? true
, lp_solve
}:

stdenv.mkDerivation rec {
  pname = "scalp";
  version = "63";

  src = fetchgit {
    url = "https://digidev.digi.e-technik.uni-kassel.de/git/scalp.git";
    rev = "185b84e4ff967f42cf2de5db4db4e6fa0cc18fb8";
    sha256 = "sha256-NyMZdJwdD3FR6uweYCclJjfcf3Y24Bns1ViwsmJ5izg=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = lib.optionals withGurobi [
    gurobi
  ] ++ lib.optionals withCplex [
    cplex
  ] ++ lib.optionals withLpsolve [
    lp_solve
  ];

  cmakeFlags = [
    "-DBUILD_TESTS=ON"
    "-DCMAKE_SKIP_BUILD_RPATH=OFF"
  ] ++ lib.optionals withGurobi [
    "-DGUROBI_DIR=${gurobi}"
  ] ++ lib.optionals withCplex [
    "-DCPLEX_DIR=${cplex}"
  ];

  doCheck = true;

  meta = with lib; {
    description = "Scalable Linear Programming Library";
    homepage = "https://digidev.digi.e-technik.uni-kassel.de/scalp/";
    license = licenses.lgpl3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ wegank ];
  };
}

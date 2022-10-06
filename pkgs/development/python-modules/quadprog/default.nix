{ lib, buildPythonPackage, fetchPypi, numpy }:

buildPythonPackage rec {
  pname = "quadprog";
  version = "0.1.11";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-jjIPn38UZhQeMX5hc26BCHIOatuuU/nWlg9ybv73iNk=";
  };

  propagatedBuildInputs = [ numpy ];

  meta = with lib; {
    homepage = "https://github.com/quadprog/quadprog";
    description = "Quadratic Programming Solver";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ wegank ];
  };
}

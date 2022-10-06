{ lib, buildPythonPackage, fetchPypi, pyyaml }:

buildPythonPackage rec {
  pname = "pyngrok";
  version = "5.1.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-TQP0SmnDy8FosXN3lWqe3Pcj5328hk66NMJy2xXaRDw=";
  };

  propagatedBuildInputs = [
    pyyaml
  ];

  meta = with lib; {
    homepage = "https://github.com/alexdlaird/pyngrok";
    description = "A Python wrapper for ngrok";
    license = licenses.mit;
    maintainers = with maintainers; [ wegank ];
  };
}

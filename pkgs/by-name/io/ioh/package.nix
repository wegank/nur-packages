{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, cmake
, ninja
, mypy
, pybind11
, xmltodict
, python
}:

buildPythonPackage rec {
  pname = "ioh";
  version = "0.3.14";
  format = "other";

  disabled = pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-k9TOTS0dBicIlu/2xAMlftiRfi342mqVasFeZKQlTTc=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  propagatedBuildInputs = [
    mypy
    pybind11
    xmltodict
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_EXAMPLE" false)
    (lib.cmakeBool "BUILD_PYTHON_PACKAGE" true)
    (lib.cmakeBool "BUILD_TESTS" false)
  ];

  postInstall = ''
    mkdir -p $out/${python.sitePackages}
    mv ioh/iohcpp.cpython-*.so $out/${python.sitePackages}
  '';

  meta = {
    description = "The experimenter for Iterative Optimization Heuristics";
    homepage = "https://iohprofiler.github.io/IOHexperimenter/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ wegank ];
  };
}

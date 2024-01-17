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

  preConfigure = ''
    mkdir -p $out/${python.sitePackages}/ioh
    mv ioh/{iohcpp,__init__.py*} -t $out/${python.sitePackages}/ioh
  '';

  cmakeFlags = [
    (lib.cmakeBool "BUILD_EXAMPLE" false)
    (lib.cmakeBool "BUILD_PYTHON_PACKAGE" true)
    (lib.cmakeBool "BUILD_TESTS" false)
  ];

  postInstall = ''
    mv ioh/iohcpp.cpython-*.so $out/${python.sitePackages}/ioh
  '';

  pythonImportsCheck = [ "ioh" ];

  meta = {
    description = "The experimenter for Iterative Optimization Heuristics";
    homepage = "https://iohprofiler.github.io/IOHexperimenter/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ wegank ];
  };
}

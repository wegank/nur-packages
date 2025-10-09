{
  lib,
  python3,
  fetchPypi,
  cmake,
  ninja,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "ioh";
  version = "0.3.14";
  format = "other";

  disabled = python3.pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-k9TOTS0dBicIlu/2xAMlftiRfi342mqVasFeZKQlTTc=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  propagatedBuildInputs = with python3.pkgs; [
    mypy
    pybind11
    xmltodict
  ];

  preConfigure = ''
    mkdir -p $out/${python3.sitePackages}/ioh
    mv ioh/{iohcpp,__init__.py*} -t $out/${python3.sitePackages}/ioh
  '';

  cmakeFlags = [
    (lib.cmakeBool "BUILD_EXAMPLE" false)
    (lib.cmakeBool "BUILD_PYTHON_PACKAGE" true)
    (lib.cmakeBool "BUILD_TESTS" false)
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5")
  ];

  postInstall = ''
    mv ioh/iohcpp.cpython-*.so $out/${python3.sitePackages}/ioh
  '';

  pythonImportsCheck = [ "ioh" ];

  meta = {
    description = "The experimenter for Iterative Optimization Heuristics";
    homepage = "https://iohprofiler.github.io/IOHexperimenter/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ wegank ];
  };
}

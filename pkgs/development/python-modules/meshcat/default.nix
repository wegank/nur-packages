{ lib
, buildPythonPackage
, fetchPypi
, ipython
, u-msgpack-python
, numpy
, tornado
, pyzmq
, pyngrok
, pillow
}:

buildPythonPackage rec {
  pname = "meshcat";
  version = "0.3.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-LP4XzeT+hdByo94Bip2r9WJvgMJV//LOY7JqSNJIStk=";
  };

  propagatedBuildInputs = [
    ipython
    u-msgpack-python
    numpy
    tornado
    pyzmq
    pyngrok
    pillow
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/rdeits/meshcat-python";
    description = "WebGL-based 3D visualizer for Python";
    license = licenses.mit;
    maintainers = with maintainers; [ wegank ];
  };
}
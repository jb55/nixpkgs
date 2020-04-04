{ stdenv, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  version = "0.8.0";
  pname = "pyln-client";

  src = fetchPypi {
    inherit pname version;
    sha256 = "16l8d9fy8nq5b66nmw8l31z9js4l0mxiw9mcrg3k8myd9p34l9l3";
  };

  patchPhase = ''
    touch requirements.txt
  '';

  meta = with stdenv.lib; {
    description = "A Python client library for clightning";
    homepage = https://github.com/ElementsProject/lightning;
    license = licenses.mit;
    maintainers = with maintainers; [ jb55 ];
  };

}

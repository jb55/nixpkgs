{ stdenv, pythonPackages }:

with stdenv.lib;
pythonPackages.buildPythonApplication rec {
  pname = "spruned";
  name = "${pname}-${version}";
  version = "0.0.4b4";

  src = pythonPackages.fetchPypi {
    inherit pname version;
    sha256 = "b156ad410ae71651aafb4ffc639ad491614622a53b3cb8211fd49e2579642f18";
  };

  disabled = ! pythonPackages.pythonAtLeast "3.5";

  propagatedBuildInputs =
    with pythonPackages; [
      async-timeout
      jsonrpcserver
      sqlalchemy
      plyvel
      daemonize
      aiohttp
      pycoin
    ];

  patchPhase = ''
    sed -i 's,import spruned,,;s,spruned.__version__,"${version}",' setup.py

    substituteInPlace requirements.txt \
      --replace 'sqlalchemy==1.2.6' 'sqlalchemy==1.2.*' \
      --replace 'aiohttp==3.0.0b0' aiohttp \
      --replace 'daemonize==2.4.7' daemonize \
      --replace 'async-timeout==2.0.1' async-timeout \
      --replace 'jsonrpcserver==3.5.3' jsonrpcserver
  '';

  doCheck = false;

  meta = {
    description = "A Bitcoin lightweight pseudonode with RPC that can fetch any block or transaction";
    homepage = https://github.com/gdassori/spruned;
    maintainers = with maintainers; [ jb55 ];
    license = licenses.mit;
    platforms = platforms.linux;
  };
}

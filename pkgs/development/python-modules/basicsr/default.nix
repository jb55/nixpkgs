{ addict, pythonRelaxDepsHook, buildPythonPackage, cython, fetchPypi, future,
lib, lmdb, numpy, opencv4, pillow, pyyaml, requests, scikitimage, scipy, torch
, torchvision, tqdm, yapf, tensorboard }:

buildPythonPackage rec {
  pname = "basicsr";
  version = "1.4.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "11qy60qqxdxp1k0w0xsmjr65bdnxh29xkd0kk7d4r5pghxd5k6xq";
  };

  pythonRemoveDeps = [ "opencv-python" "tb-nightly" ];

  pythonImportsCheck = [ "basicsr" ];

  nativeBuildInputs = [ pythonRelaxDepsHook ];
  buildInputs = [ cython numpy torch ];
  propagatedBuildInputs = [
    addict
    future
    lmdb
    numpy
    opencv4
    pillow
    pyyaml
    requests
    scikitimage
    scipy
    torch
    torchvision
    tqdm
    yapf
    tensorboard
  ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description = "Open Source Image and Video Super-Resolution Toolbox";
    homepage = "https://github.com/xinntao/BasicSR";
    maintainers = with maintainers; [ jb55 ];
  };
}

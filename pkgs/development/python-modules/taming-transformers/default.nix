{ lib
, buildPythonPackage
, fetchPypi

# propagates

, numpy
, torch
, torchvision
, omegaconf
, pytorch-lightning
, tqdm

}:

buildPythonPackage rec {
  pname = "taming-transformers";
  version = "0.0.6";

  src = fetchPypi {
    pname = "taming-transformers-rom1504";
    inherit version;
    sha256 = "sha256-c/5fwRCKzO5CNu5pduCYerI2r60K8Gy58DdkGpCNLDI=";
  };

  propagatedBuildInputs = [
    numpy
    omegaconf
    pytorch-lightning
    torch
    torchvision
    tqdm
  ];

  pythonImportsCheck = [ "taming" ];

  meta = with lib; {
    description = "Taming Transformers for High-Resolution Image Synthesis";
    homepage = "https://github.com/CompVis/taming-transformers";
    license = licenses.mit;
    maintainers = with maintainers; [ hexa jb55 ];
  };
}

{ buildPythonPackage, fetchPypi, lib, numpy, packaging, psutil, pyyaml, torch 

  # tests
, pytest
, tox
, pytest-xdist
, pytest-subtests
, pytestCheckHook
, parameterized
}:

buildPythonPackage rec {
  pname = "accelerate";
  version = "0.14.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-McW8xAVk74SbW8HEQkpDzK+eJkE7fficLja/gfBw/UQ=";
  };

  propagatedBuildInputs = [ numpy packaging psutil pyyaml torch ];

  # many things seems untestable atm
  doCheck = false;

  disabledTests = [
    # expects gpu
    "test_can_disable_even_batches"
    "test_default_ensures_even_batch_sizes"
  ];

  checkInputs = [
    pytest
    pytestCheckHook
    pytest-xdist
    pytest-subtests
    parameterized
  ];

  meta = with lib; {
    description = "Run a PyTorch training script on any kind of device";
    homepage = "https://github.com/huggingface/accelerate";
  };
}

{ callPackage, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "7.5.18";
  md5 = "4b3bcecf0dfc35928a0898793cf3e4c6";
  url = "http://developer.download.nvidia.com/compute/cuda/7.5/Prod/local_installers/cuda_${version}_linux.run";
})

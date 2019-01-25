{ stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "spirv-headers-${version}";
  version = "git-2019-01-24";

  src = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "SPIRV-Headers";
    rev = "79b6681aadcb53c27d1052e5f8a0e82a981dbf2f";
    sha256 = "0flng2rdmc4ndq3j71h6wk1ibcjvhjrg2rzd6rv445vcsf0jh2pj";
  };

  nativeBuildInputs = [ cmake ];

  meta = with stdenv.lib; {
    inherit (src.meta) homepage;
    description = "SPIRV Headers";
    license = licenses.asl20;
    maintainers = with maintainers; [ jb55 ];
    platforms = with platforms; linux;
  };
}

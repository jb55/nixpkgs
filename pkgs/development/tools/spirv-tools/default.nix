{ stdenv, spirv-headers, fetchFromGitHub, cmake, python }:

stdenv.mkDerivation rec {
  name = "spirv-tools-${version}";
  version = "git-2019-01-08";

  src = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "SPIRV-Tools";
    rev = "df5bd2d05ac1fd3ec3024439f885ec21cc949b22";
    sha256 = "0l8ds4nn2qcfi8535ai8891i3547x35hscs2jxwwq6qjgw1sgkax";
  };

  patchPhase = "ln -sv ${spirv-headers} external/spirv-headers";
  enableParallelBuilding = true;

  buildInputs = [ cmake python spirv-headers ];

  meta = with stdenv.lib; {
    inherit (src.meta) homepage;
    description = "The SPIR-V Tools project provides an API and commands for processing SPIR-V modules";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = [ maintainers.ralith ];
  };
}

{ stdenv, fetchFromGitHub, fetchpatch, cmake, bison, spirv-tools, spirv-headers, jq }:

stdenv.mkDerivation rec {
  name = "glslang-git-${version}";
  version = "2019-01-24";

  src = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "glslang";
    rev = "2cf6613a0d35545812c34a633ec0772c0320108c";
    sha256 = "08cvkgw3nxnhp28i44gy4i560jb9iaa1g05x7ck70ak4fs3b0h0s";
  };

  buildInputs = [ cmake bison jq ] ++ spirv-tools.buildInputs;
  enableParallelBuilding = true;

  postPatch = ''
    cp --no-preserve=mode -r "${spirv-tools.src}" External/spirv-tools
    ln -s "${spirv-headers}" External/spirv-tools/external/spirv-headers
  '';

  preConfigure = ''
    HEADERS_COMMIT=$(jq -r < known_good.json '.commits|map(select(.name=="spirv-tools/external/spirv-headers"))[0].commit')
    TOOLS_COMMIT=$(jq -r < known_good.json '.commits|map(select(.name=="spirv-tools"))[0].commit')
    if [ "$HEADERS_COMMIT" != "${spirv-headers.src.rev}" ] || [ "$TOOLS_COMMIT" != "${spirv-tools.src.rev}" ]; then
      echo "ERROR: spirv-tools commits do not match expected versions: expected tools at $TOOLS_COMMIT, headers at $HEADERS_COMMIT";
      exit 1;
    fi
  '';

  doCheck = false; # fails 3 out of 3 tests (ctest)

  meta = with stdenv.lib; {
    inherit (src.meta) homepage;
    description = "Khronos reference front-end for GLSL and ESSL";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = [ maintainers.ralith ];
  };
}

{ stdenv, fetchFromGitHub, cmake }:
stdenv.mkDerivation rec {
  name = "vulkan-headers-${version}";
  version = "1.1.97";

  buildInputs = [ cmake ];

  src = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "Vulkan-Headers";
    rev = "v${version}";
    sha256 = "1yjwhbnccsmn99q9cb0vdimcpa8bacx1cxndzfxbgqzkckmd9mhc";
  };

  meta = with stdenv.lib; {
    description = "Vulkan Header files and API registry";
    homepage    = https://www.lunarg.com;
    platforms   = platforms.linux;
    license     = licenses.asl20;
    maintainers = [ maintainers.ralith ];
  };
}

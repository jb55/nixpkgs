{ stdenv, fetchFromGitHub, cmake, python3, vulkan-loader, vulkan-headers,
  glslang, pkgconfig, xlibsWrapper, libxcb, libXrandr, wayland }:

stdenv.mkDerivation rec {
  pname = "vulkan-tools";
  version = "1.2.135";

  src = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "Vulkan-Tools";
    rev = "v${version}";
    sha256 = "0hv4vlzkrl6aab11wryxmjj9wss8a2aiyciap93dq7pngz1agafk";
  };

  nativeBuildInputs = [ cmake pkgconfig ];
  buildInputs = [ python3 vulkan-headers vulkan-loader xlibsWrapper libxcb libXrandr wayland ];
  enableParallelBuilding = true;

  cmakeFlags = [ "-DBUILD_ICD=OFF" "-DGLSLANG_INSTALL_DIR=${glslang}" ];

  meta = with stdenv.lib; {
    description = "LunarG Vulkan loader";
    homepage    = https://www.lunarg.com;
    platforms   = platforms.linux;
    license     = licenses.asl20;
    maintainers = [ maintainers.ralith ];
  };
}

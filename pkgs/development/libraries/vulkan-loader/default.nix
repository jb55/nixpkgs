{ stdenv, fetchFromGitHub, cmake, python3, vulkan-headers, pkgconfig
, xlibsWrapper, libxcb, libXrandr, libXext, wayland, addOpenGLRunpath }:

stdenv.mkDerivation rec {
  pname = "vulkan-loader";
  version = "1.2.135";

  src = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "Vulkan-Loader";
    rev = "v${version}";
    sha256 = "1sk00zmx6x7w8m3i79jzk9b44v5vpjayjba6g0j5wn76ai7nbhq4";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ cmake python3 xlibsWrapper libxcb libXrandr libXext wayland ];
  enableParallelBuilding = true;

  cmakeFlags = [
    "-DSYSCONFDIR=${addOpenGLRunpath.driverLink}/share"
    "-DVULKAN_HEADERS_INSTALL_DIR=${vulkan-headers}"
  ];

  outputs = [ "out" "dev" ];

  meta = with stdenv.lib; {
    description = "LunarG Vulkan loader";
    homepage    = https://www.lunarg.com;
    platforms   = platforms.linux;
    license     = licenses.asl20;
    maintainers = [ maintainers.ralith ];
  };
}

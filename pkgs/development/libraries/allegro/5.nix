{ stdenv, fetchFromGitHub, texinfo, libXext, libX11, xorgproto
, libXpm, libXt, libXcursor, alsaLib, cmake, zlib, libpng, libvorbis
, libXxf86dga, libXxf86misc, libXxf86vm, openal, libGLU_combined, libjpeg, flac
, libXi, libXfixes, freetype, libopus, libtheora , physfs, enet, pkgconfig, gtk2
, pcre, libpulseaudio, libpthreadstubs , libXdmcp
}:

stdenv.mkDerivation rec {
  name = "allegro-${version}";
  version = "5.2.4.0";

  src = fetchFromGitHub {
    owner = "liballeg";
    repo = "allegro5";
    rev = version;
    sha256 = "01y3hirn5b08f188nnhb2cbqj4vzysr7l2qpz2208srv8arzmj2d";
  };

  buildInputs = [
    texinfo libXext libX11 xorgproto libXpm libXt libXcursor alsaLib cmake zlib
    libpng libvorbis libXxf86dga libXxf86misc libXxf86vm openal libGLU_combined
    libjpeg flac libXi libXfixes enet libtheora freetype physfs libopus
    pkgconfig gtk2 pcre libXdmcp libpulseaudio libpthreadstubs
  ];

  patchPhase = ''
    sed -e 's@/XInput2.h@/XI2.h@g' -i CMakeLists.txt "src/"*.c
  '';

  cmakeFlags = [ "-DCMAKE_SKIP_RPATH=ON" ];

  meta = with stdenv.lib; {
    description = "A game programming library";
    homepage = https://liballeg.org/;
    license = licenses.zlib;
    maintainers = [ maintainers.raskin ];
    platforms = platforms.linux;
  };
}

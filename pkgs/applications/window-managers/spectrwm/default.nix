{ fetchFromGitHub
, coreutils
, libX11
, libXrandr
, libXcursor
, libXft
, libXt
, libxcb
, xcbutil
, xcb-util-cursor
, xcbutilkeysyms
, xcbutilwm
, stdenv
}:

stdenv.mkDerivation rec {
  name = "spectrwm-${version}";
  version = "2.6.2";

  src = fetchFromGitHub {
    rev = "46020d87811d1d3ec05035cd44db5fcd7c2bcd2b";
    owner = "conformal";
    repo = "spectrwm";
    sha256 = "12lp7bzrnj5fqjy06cgy1q626xhalv30gbcd95wgls4rfrb8zyq9";
  };

  buildInputs = [
    libX11
    libxcb
    libXrandr
    libXcursor
    libXft
    libXt
    xcbutil
    xcb-util-cursor
    xcbutilkeysyms
    xcbutilwm
  ];

  doCheck = false;

  preBuild = "cd linux";
  installPhase = "PREFIX=$out make install";

  meta = with stdenv.lib; {
    description = "A tiling window manager";
    homepage    = "https://github.com/conformal/spectrwm";
    maintainers = with maintainers; [ jb55 ];
    license     = licenses.isc;
    platforms   = platforms.all;

    longDescription = ''
      spectrwm is a small dynamic tiling window manager for X11. It
      tries to stay out of the way so that valuable screen real estate
      can be used for much more important stuff. It has sane defaults
      and does not require one to learn a language to do any
      configuration. It was written by hackers for hackers and it
      strives to be small, compact and fast.
    '';
  };

}

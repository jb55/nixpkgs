# FIXME: upgrading qt5Full (Qt 5.3) to qt5.{base,multimedia} (Qt 5.4) breaks
# the default Qt audio capture source!
{ stdenv, fetchFromGitHub, fftw, freeglut, qt5Full
, alsaSupport ? false, alsaLib ? null
, jackSupport ? false, libjack2 ? null }:

assert alsaSupport -> alsaLib != null;
assert jackSupport -> libjack2 != null;

let version = "1.0.5"; in
stdenv.mkDerivation {
  name = "fmit-${version}";

  src = fetchFromGitHub {
    sha256 = "1p49ykg7mf62xrn08fqss8yr1nf53mm8w9zp2sgcy48bfsa9xbpy";
    rev = "v${version}";
    repo = "fmit";
    owner = "gillesdegottex";
  };

  buildInputs = [ fftw freeglut qt5Full ]
    ++ stdenv.lib.optional alsaSupport [ alsaLib ]
    ++ stdenv.lib.optional jackSupport [ libjack2 ];

  postPatch = ''
    substituteInPlace fmit.pro --replace '$$FMITVERSIONGITPRO' '${version}'
    substituteInPlace distrib/fmit.desktop \
      --replace "Icon=fmit" "Icon=$out/share/pixmaps/fmit.svg"
    substituteInPlace src/main.cpp --replace "PREFIX" "\"$out\""
  '';

  configurePhase = ''
    qmake \
      CONFIG+=${stdenv.lib.optionalString alsaSupport "acs_alsa"} \
      CONFIG+=${stdenv.lib.optionalString jackSupport "acs_jack"} \
      fmit.pro
  '';

  enableParallelBuilding = true;

  installPhase = ''
    install -D fmit $out/bin/fmit
    install -Dm644 distrib/fmit.desktop $out/share/applications/fmit.desktop
    install -Dm644 ui/images/fmit.svg $out/share/pixmaps/fmit.svg
    mkdir -p $out/share/fmit
    cp -R tr $out/share/fmit
  '';

  meta = with stdenv.lib; {
    inherit version;
    description = "Free Musical Instrument Tuner";
    longDescription = ''
      FMIT is a graphical utility for tuning musical instruments, with error
      and volume history, and advanced features.
    '';
    homepage = http://gillesdegottex.github.io/fmit/;
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ nckx ];
  };
}

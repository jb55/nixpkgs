{ stdenv, pidgin, libjson, glibc, json_glib, protobufc, fetchhg }:

stdenv.mkDerivation rec {
  name = "purple-hangouts-${version}";
  version = "git-2016-08-03";

  src = fetchhg {
    url = "https://bitbucket.org/EionRobb/purple-hangouts";
    rev = "c5f97d3d725eee3902376d73c33e98067d38c50a";
    sha256 = "0h3xapwcbjdpxl22xwj0ywm60zifrkd2sbmf7jwrkhljlc2lp5bk";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  patchPhase = ''
    sed -i"" 's,.*HANGOUTS_ICONS_DEST = .*,HANGOUTS_ICONS_DEST = $(out)/share/pixmaps/pidgin/protocols,g' Makefile
    sed -i"" 's,.*HANGOUTS_DEST = .*,HANGOUTS_DEST = $(out)/lib/pidgin,g' Makefile
  '';

  buildInputs = [ pidgin libjson glibc json_glib protobufc ];

  meta = with stdenv.lib; {
    description = "Pidgin Hangouts plugin";
    homepage = "https://bitbucket.org/EionRobb/purple-hangouts";
    maintainers = with maintainers; [ jb55 ];
    license = licenses.gpl3;
  };
}

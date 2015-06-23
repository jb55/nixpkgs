{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  version = "1.4.2";
  name = "clib-${version}";

  src = fetchurl {
    url = "https://github.com/clibs/clib/archive/1.4.2.tar.gz";
    sha256 = "04qy8d5gz95zsf9jfr3fryfykma1sgzv2061qbk4qnlm225dkwy1";
  };

  makeFlags = "PREFIX=$(out)";

  meta = with stdenv.lib; {
    description = "C micro-package manager";
    homepage = "https://github.com/clibs/clib";
    maintainers = with maintainers; [ jb55 ];
    license = licenses.mit;
  };
}

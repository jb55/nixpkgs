{ stdenv, fetchgit, gcc, gmp, libsigsegv, openssl, automake, autoconf, ragel,
  cmake, re2c, libtool, ncurses, perl, zlib, python }:

stdenv.mkDerivation rec {

  name = "urbit-${version}";
  version = "2016.06.02";

  src = fetchgit {
    url = "https://github.com/urbit/urbit.git";
    rev = "566dcf211fd69df5c1af2a5874868a4f811ac04f";
    sha256 = "1q30dc3lyvqr0243hsczcnga6svm7k0izw7yqbzj44pvdr4myz76";
  };

  buildInputs = with stdenv.lib; [
    gcc gmp libsigsegv openssl automake autoconf ragel cmake re2c libtool
    ncurses perl zlib python
  ];

  configurePhase = ''
    :
  '';

  buildPhase = ''
    sed -i 's/-lcurses/-lncurses/' Makefile
    mkdir -p $out
    cp -r . $out/
    cd $out
    make
  '';

  installPhase = ''
    :
  '';

  meta = with stdenv.lib; {
    description = "an operating function";
    homepage = http://urbit.org/preview/~2015.9.25/materials;
    license = licenses.mit;
    maintainers = with maintainers; [ mudri ];
  };
}

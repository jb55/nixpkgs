{ stdenv, lib, fetchurl, perl, makeWrapper, perlPackages }:

let
  perlDeps = with perlPackages; [ TimeDate ];
in
stdenv.mkDerivation rec {
  version = "3.20";
  name = "mb2md-${version}";

  src = fetchurl {
    url = "http://batleth.sapienti-sat.org/projects/mb2md/mb2md-${version}.pl.gz";
    sha256 = "0bvkky3c90738h3skd2f1b2yy5xzhl25cbh9w2dy97rs86ssjidg";
  };

  buildInputs = [ makeWrapper perl ];

  unpackPhase = ''
    sourceRoot=.
    gzip -d < $src > mb2md.pl
  '';

  installPhase = ''
    install -D $sourceRoot/mb2md.pl $out/bin/mb2md
  '';

  postFixup = ''
    wrapProgram $out/bin/mb2md \
      --set PERL5LIB "${lib.makePerlPath perlDeps}"
  '';

  meta = with stdenv.lib; {
    description = "mbox to maildir tool";
    license = [ licenses.publicDomain ];
    platforms = platforms.all;
    maintainers = [ maintainers.jb55 ];
  };
}

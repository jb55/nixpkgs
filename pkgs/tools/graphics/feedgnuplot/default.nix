{ stdenv, fetchFromGitHub, perlPackages }:

perlPackages.buildPerlPackage rec {
  name = "feedgnuplot-${version}";
  version = "1.44";

  src = fetchFromGitHub {
    owner = "dkogan";
    repo  = "feedgnuplot";
    rev   = "v${version}";
    sha256 = "1xgmkyfzqcmiy9zvzczzba78vmlvckiwd90ja0gd548n4rpa4jk3";
  };

  outputs = [ "out" ];
  propagatedBuildOutputs = [ ];

  buildInputs = with perlPackages; [ ListMoreUtils ]; # plugins will need some

  installPhase = ''
    mkdir -p $out/bin
    cp bin/feedgnuplot $out/bin
  '';

  meta = with stdenv.lib; {
    description = "Plot realtime and stored data from the commandline, using gnuplot";
    homepage = src.meta.homepage;
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}

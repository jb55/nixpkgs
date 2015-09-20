{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "miniupnpc-1.9.20150917";

  src = fetchurl {
    url = "http://miniupnp.free.fr/files/download.php?file=${name}.tar.gz";
    sha256 = "1nhiixfmlagcv9srni19r95n1v069rlq98fn8x4xpsf154lw71rh";
    name = "${name}.tar.gz";
  };

  doCheck = true;

  installFlags = "PREFIX=$(out) INSTALLPREFIX=$(out)";

  meta = {
    homepage = http://miniupnp.free.fr/;
    description = "A client that implements the UPnP Internet Gateway Device (IGD) specification";
    platforms = stdenv.lib.platforms.linux;
  };
}

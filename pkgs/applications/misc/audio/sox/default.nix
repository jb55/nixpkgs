{ lib, stdenv, fetchurl
, enableAlsa ? true, alsaLib ? null
, enableLibao ? true, libao ? null
, enableLame ? false, lame ? null
, enableLibmad ? true, libmad ? null
, enableLibogg ? true, libogg ? null, libvorbis ? null
, enableFLAC ? true, flac ? null
, enablePNG ? true, libpng ? null
}:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "sox-14.4.2";

  src = fetchurl {
    url = "mirror://sourceforge/sox/${name}.tar.gz";
    sha256 = "0v2znlxkxxcd3f48hf3dx9pq7i6fdhb62kgj7wv8xggz8f35jpxl";
  };

  buildInputs =
    optional (enableAlsa && stdenv.isLinux) alsaLib ++
    optional enableLibao libao ++
    optional enableLame lame ++
    optional enableLibmad libmad ++
    optionals enableLibogg [ libogg libvorbis ] ++
    optional enableFLAC flac ++
    optional enablePNG libpng;

  meta = {
    description = "Sample Rate Converter for audio";
    homepage = http://sox.sourceforge.net/;
    maintainers = [ lib.maintainers.marcweber ];
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}

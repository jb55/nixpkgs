{ stdenv, git, fetchFromGitHub, execpath ? "/run/current-system/sw/bin/" }:

stdenv.mkDerivation rec {
  name = "gophernicus";
  version = "git-2014-12-14";

  src = fetchFromGitHub {
    owner  = "gophernicus";
    repo   = name;
    rev    = "007082d58543ca51d7982044933413330a4e57d8";
    sha256 = "0v6fhis32w7p4hn7xh38rzfbpzc1p45pxsyppmqpy38qljdd7jkl";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp in.gophernicus $out/bin
  '';

  patchPhase = ''
    substituteInPlace gophernicus.h \
      --replace "#define SAFE_PATH	\"/usr/bin:/bin\"" \
                "#define SAFE_PATH  \"${execpath}\""
  '';

  nativeBuildInputs = [ git ];

  meta = with stdenv.lib; {
    description = "Gopher server";
    homepage = "https://github.com/prologic/gophernicus";
    maintainers = with maintainers; [ jb55 ];
    license = licenses.free;
  };
}

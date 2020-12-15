{ stdenv, fetchFromGitHub, nodePackages }:

stdenv.mkDerivation rec {
  name = "webtorrent-hook";
  version = builtins.substring 0 7 src.rev;

  src = fetchFromGitHub {
    owner = "noctuid";
    repo = "mpv-webtorrent-hook";
    rev = "755c6348e10279cb6049264c319e86afc1f830f3";
    sha256 = "2igEC1Z2yAObx9boJexFF+b25V2tylyVyNfF7xLd3YI=";
  };

  dontBuild = true;

  buildInputs = [ nodePackages.webtorrent-cli ];

  installPhase = ''
    mkdir -p $out/share/mpv/scripts
    cp webtorrent-hook.lua $out/share/mpv/scripts/
  '';

  passthru.scriptName = "webtorrent-hook.lua";

  meta = with stdenv.lib; {
    description = "Stream torrents in mpv using webtorrent-cli";
    homepage = "https://github.com/noctuid/mpv-webtorrent-hook";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ yoctocell ];
  };
}

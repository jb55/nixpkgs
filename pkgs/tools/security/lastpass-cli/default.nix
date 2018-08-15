{ stdenv, lib, fetchFromGitHub, asciidoc, cmake, docbook_xsl, pkgconfig
, bash-completion, makeWrapper, openssl, curl, libxml2, libxslt, pinentry_gtk2
, pinentryPath ? null, guiSupport ? false }:

let
  pinpath =
    if pinentryPath == null
      then "${pinentry_gtk2}/bin/pinentry"
      else pinentryPath;
in
stdenv.mkDerivation rec {
  pname = "lastpass-cli";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "lastpass";
    repo = pname;
    rev = "v${version}";
    sha256 = "168jg8kjbylfgalhicn0llbykd7kdc9id2989gg0nxlgmnvzl58a";
  };

  nativeBuildInputs = [ asciidoc cmake docbook_xsl pkgconfig makeWrapper ];

  buildInputs = [
    bash-completion curl openssl libxml2 libxslt
  ];

  enableParallelBuilding = true;

  installTargets = [ "install" "install-doc" ];

  postInstall = ''
    install -Dm644 -T ../contrib/lpass_zsh_completion $out/share/zsh/site-functions/_lpass
    install -Dm644 -T ../contrib/completions-lpass.fish $out/share/fish/vendor_completions.d/lpass.fish
  '' +
  (if guiSupport then ''
    wrapProgram $out/bin/lpass --set LPASS_PINENTRY "${pinpath}"
  '' else "");

  meta = with lib; {
    description = "Stores, retrieves, generates, and synchronizes passwords securely";
    homepage    = "https://github.com/lastpass/lastpass-cli";
    license     = licenses.gpl2Plus;
    platforms   = platforms.unix;
    maintainers = with maintainers; [ cstrahan ];
  };
}

{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  pname = "trezorencrypt";
  version = "0.1.1";

  # Fixes Cgo related build failures (see https://github.com/NixOS/nixpkgs/issues/25959 )
  hardeningDisable = [ "fortify" ];

  goPackagePath = "github.com/petrkr/trezorencrypt";

  src = fetchFromGitHub {
    owner  = "petrkr";
    repo   = "trezorencrypt";
    rev    = "v${version}";
    sha256 = "107dwbl8rap61g33n57hi7z82njq68zf8q2yfxc13xcqjl1dzd2j";
  };

  # Compile helper Askpass from debian cryptsetup package
  postInstall = ''
  gcc -pedantic -std=c99 $src/tools/askpass.c -o $bin/bin/trezor-askpass
  '';

  goDeps = ./deps.nix;

  meta = with stdenv.lib; {
    description = "Pipeline utlility to encrypt/decrypt values using TREZOR device";
    homepage = https://www.github.com/petrkr/trezorencrypt;
    license = licenses.lgpl3;
    maintainers = with maintainers; [ petrkr ];
    platforms = platforms.linux;
  };
}

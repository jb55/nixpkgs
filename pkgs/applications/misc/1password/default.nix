{ stdenv, fetchzip, fetchpgpkey, verifySignatureHook }:

stdenv.mkDerivation rec {
  pname = "1password";
  version = "0.5.5";
  src =
    if stdenv.hostPlatform.system == "i686-linux" then
      fetchzip {
        url = "https://cache.agilebits.com/dist/1P/op/pkg/v${version}/op_linux_386_v${version}.zip";
        sha256 = "1jwkvj6xxfgn08j6wzwcra3p1dp04vblzr2g5s1y3bj4r7gs4gax";
        stripRoot = false;
      }
    else if stdenv.hostPlatform.system == "x86_64-linux" then
      fetchzip {
        url = "https://cache.agilebits.com/dist/1P/op/pkg/v${version}/op_linux_amd64_v${version}.zip";
        sha256 = "1svic2b2msbwzfx3qxfglxp0jjzy3p3v78273wab942zh822ld8b";
        stripRoot = false;
      }
    else if stdenv.hostPlatform.system == "x86_64-darwin" then
      fetchzip {
        url = "https://cache.agilebits.com/dist/1P/op/pkg/v${version}/op_darwin_amd64_v${version}.zip";
        sha256 = "03bnwn06066hvp0n30260mhvkjr60dl93nj9l7p6a0ndcv7w77r8";
        stripRoot = false;
      }
    else throw "Architecture not supported";

  nativeBuildInputs = [ verifySignatureHook ];

  signaturePublicKey = fetchpgpkey {
    url = https://keybase.io/1password/pgp_keys.asc;
    fingerprint = "3FEF9748469ADBE15DA7CA80AC2D62742012EA22";
    sha256 = "1v9gic59a3qim3fcffq77jrswycww4m1rd885lk5xgwr0qnqr019";
  };

  doCheck = true;
  checkPhase = ''
    verifySignature op.sig op
  '';

  installPhase = ''
    install -D op $out/bin/op
  '';
  postFixup = stdenv.lib.optionalString stdenv.isLinux ''
    patchelf \
      --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      $out/bin/op
  '';

  meta = with stdenv.lib; {
    description  = "1Password command-line tool";
    homepage     = https://support.1password.com/command-line/;
    downloadPage = https://app-updates.agilebits.com/product_history/CLI;
    maintainers  = with maintainers; [ joelburget ];
    license      = licenses.unfree;
    platforms    = [ "i686-linux" "x86_64-linux" "x86_64-darwin" ];
  };
}

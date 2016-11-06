{ stdenv, libsodium, fetchFromGitHub, pkgconfig, autoreconfHook, openssl, db62, boost
, zlib, gtest, gmock, miniupnpc, callPackage, gmp, qt4, utillinux, protobuf, qrencode, libevent
, withGui }:

let snark = callPackage ./snark { };
in
with stdenv.lib;
stdenv.mkDerivation rec{

  name = "zclassic" + (toString (optional (!withGui) "d")) + "-" + version;
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "z-classic";
    repo  = "zclassic";
    rev = "03842b569d687b4e77f1a35a548c11d7661823ae";
    sha256 = "06k9nasirll1g7gkm040c33am7aips5h1vh64j58ssxdzpyljndr";
  };

  enableParallelBuilding = true;

  buildInputs = [ pkgconfig gtest gmock gmp snark autoreconfHook openssl db62 boost zlib
                  miniupnpc protobuf libevent snark libsodium]
                  ++ optionals stdenv.isLinux [ utillinux ]
                  ++ optionals withGui [ qt4 qrencode ];

  configureFlags = [ "LIBSNARK_INCDIR=${snark}/include/libsnark"
                     "--with-boost-libdir=${boost.out}/lib"
                   ] ++ optionals withGui [ "--with-gui=qt4" ];

  patchPhase = ''
    sed -i"" '/^\[LIBSNARK_INCDIR/d'               configure.ac
    sed -i"" 's,-lboost_system-mt,-lboost_system,' configure.ac
    sed -i"" 's,-fvisibility=hidden,,g'            src/Makefile.am
  '';

  postInstall = ''
    cp zcutil/fetch-params.sh $out/bin/zcash-fetch-params
  '';

  meta = {
    description = "Peer-to-peer, anonymous electronic cash system";
    homepage = "https://z.cash/";
    maintainers = with maintainers; [ jb55 ];
    license = licenses.mit;
    platforms = platforms.unix;
  };
}

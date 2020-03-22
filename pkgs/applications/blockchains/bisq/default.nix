{ stdenv, fetchurl, fetchFromGitHub, makeWrapper, patchelf
 , gradle, jdk11, glibc, perl, torbrowser, gnutar, xz
 , zlib, libevent, openssl 
}:

let 
  version = "1.2.9";

  srcs = {
    bisq = fetchFromGitHub {
      owner = "bisq-network";
      repo = "bisq";
      rev = "v${version}";
      sha256 = "11hrnk9cq268kbxxplmg5jan2163c990bvmvp5qc0w0yahfm48wj";
    };

    # The following are binaries used by Gradle when building the sources.
    # Even if I could get them build from their sources using Nix, I have
    # no clue how to get Gradle to use them. Thus, these binaries are patchelf'ed below.
    protoc = fetchurl {
      url = "https://repo.maven.apache.org/maven2/com/google/protobuf/protoc/3.10.0/protoc-3.10.0-linux-x86_64.exe";
      sha256 = "eed3ea189a99e3ad4e4209332e7161b255dc8f39bbde4c8e9fc25535f0f6f4f5";
    };

    protoc-gen = fetchurl {
      url = "https://repo.maven.apache.org/maven2/io/grpc/protoc-gen-grpc-java/1.25.0/protoc-gen-grpc-java-1.25.0-linux-x86_64.exe";
      sha256 = "a712c0af4a0f7261a4880398072da6b482beca2307c2e5c42592d96841ca0ec2";
    };
  };

  protoc = mkBinaryDepDerivation srcs.protoc;
  protoc-gen = mkBinaryDepDerivation srcs.protoc-gen;

  # fake build to pre-download deps into fixed-output derivation
  deps = stdenv.mkDerivation rec {
    pname = "bisq-deps";
    src = srcs.bisq;
    inherit version;

    buildInputs = [ gradle jdk11 patchelf protoc protoc-gen perl ];
  
    buildPhase = ''
      export GRADLE_USER_HOME=$(mktemp -d)
  
      # Put the protobuf binaries where Gradle expects to find them, so that it uses our patchelf'ed versions
      mkdir -p $GRADLE_USER_HOME/caches/modules-2/files-2.1/com.google.protobuf/protoc/3.10.0/e7ba2967f692c3bd2bd417f6a305bcb6a8c6a357
      mkdir -p $GRADLE_USER_HOME/caches/modules-2/files-2.1/io.grpc/protoc-gen-grpc-java/1.25.0/52e4b308cae18ae37af4722eea3f6bc0e0b928c6
      cp ${protoc}/bin/* $GRADLE_USER_HOME/caches/modules-2/files-2.1/com.google.protobuf/protoc/3.10.0/e7ba2967f692c3bd2bd417f6a305bcb6a8c6a357
      cp ${protoc-gen}/bin/* $GRADLE_USER_HOME/caches/modules-2/files-2.1/io.grpc/protoc-gen-grpc-java/1.25.0/52e4b308cae18ae37af4722eea3f6bc0e0b928c6
  
      gradle --no-daemon -i -Dorg.gradle.java.home=${jdk11.home} installDist
    '';
  
    installPhase = ''
      # Maven-ize paths
      find $GRADLE_USER_HOME/caches/modules-2 -type f -regex '.*\.\(jar\|pom\)' \
        | perl -pe 's#(.*/([^/]+)/([^/]+)/([^/]+)/[0-9a-f]{30,40}/([^/\s]+))$# ($x = $2) =~ tr|\.|/|; "install -Dm444 $1 \$out/$x/$3/$4/$5" #e' \
        | sh

      find $GRADLE_USER_HOME/caches/modules-2 -type f -regex '.*\.\(exe\)' \
        | perl -pe 's#(.*/([^/]+)/([^/]+)/([^/]+)/[0-9a-f]{30,40}/([^/\s]+))$# ($x = $2) =~ tr|\.|/|; "install -Dm555 $1 \$out/$x/$3/$4/$5" #e' \
        | sh
    '';

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "1z22bd920s2jn8vigg7g8achjxs89vvxcdxrznpvqc26big97z7m";
  };

  # The "deps" above includes Tor executables from the upstream Tor browser project.
  # See https://github.com/JesusMcCloud/tor-binary/blob/master/tor-binary-linux64/pom.xml
  # Said executables end up in $HOME/.local/share/Bisq/btc_mainnet/tor, and of course
  # they cannot be executed as-is on Nix. The following derivation provides executables
  # to be injected into the "tor-binary" jar file.
  tor = let 
    libPath = stdenv.lib.makeLibraryPath [ xz zlib libevent openssl ];
  in stdenv.mkDerivation rec {
    name = "bisq-tor-binary";
    src = torbrowser;
    buildInputs = [ patchelf gnutar ];

    buildPhase = ''
      mkdir build
      patchelf --set-rpath "${libPath}" share/tor-browser/TorBrowser/Tor/tor
      ${gnutar}/bin/tar -C share/tor-browser/TorBrowser/Tor -cf build/tor.tar .
      ${xz}/bin/xz build/tor.tar
    '';

    installPhase = ''
      mkdir -p $out/native/linux/x64
      cp build/tor.tar.xz $out/native/linux/x64
    '';
  };

  mkBinaryDepDerivation = src: stdenv.mkDerivation rec {
    name = "bisq-binary";
    inherit src; 
  
    dontUnpack = true;
    buildInputs = [ patchelf ];
  
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/
  
      chmod +x $out/bin/*
    '';
  
    postFixup = ''
      patchelf --set-interpreter ${glibc}/lib64/ld-linux-x86-64.so.2 $out/bin/$(basename $src)
      mv $out/bin/$(basename $src) $out/bin/$(basename $src | tail -c +34)
    '';
  };

  # TODO: Add DesktopItem
in stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "bisq";
  src = srcs.bisq;

  inherit version;

  buildInputs = [ gradle jdk11 deps makeWrapper ];
  buildNativeInputs = [ torbrowser ];

  buildPhase = ''
    export GRADLE_USER_HOME=$(mktemp -d)
    export DEPS_DIR=$(mktemp -d)

    # Make a read-write directory with the deps
    # so Gradle can copy files which don't need to be copied. :facepalm
    cp -R ${deps}/* $DEPS_DIR/
    chmod -vR u+w $DEPS_DIR/*

    # Point to offline repo only
    sed -ie "s#https://jitpack.io#$DEPS_DIR#" build.gradle
    sed -ie "s#mavenCentral()##" build.gradle
    sed -ie "s#jcenter()#maven { url '$DEPS_DIR' }#" build.gradle

    gradle --offline --no-daemon -i -Dorg.gradle.java.home=${jdk11.home} installDist
  '';

  installPhase = ''
    mkdir -p $out/bin

    cp bisq-* $out/bin/ 
    cp -R lib $out/
  '';

  postFixup = ''
    for f in "cli" "daemon" "desktop" "monitor" "pricenode" "relay" "seednode" "statsnode"
    do
      substituteInPlace $out/bin/bisq-$f --replace "\`pwd -P\`" $out
      wrapProgram $out/bin/bisq-$f --set JAVA_HOME ${jdk11.home}
    done

    ${jdk11}/bin/jar -uf $out/lib/tor-binary-linux64-* -C ${tor} native/linux/x64/tor.tar.xz 
  '';

  meta = {
    description = "An open-source, peer-to-peer application that allows you to buy and sell cryptocurrencies in exchange for national currencies.";
    homepage = https://bisq.network;
    license = stdenv.lib.licenses.agpl3;
    platforms = [ "x86_64-linux" ];
  };
}

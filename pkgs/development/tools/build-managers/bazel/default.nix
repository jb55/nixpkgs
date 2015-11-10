{ stdenv, fetchFromGitHub, jdk, zip, zlib, protobuf3_0, pkgconfig, libarchive, unzip, which, makeWrapper }:

let protobuf = protobuf3_0;
in stdenv.mkDerivation rec {
  name = "bazel-${version}";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "google";
    repo = "bazel";
    rev = "0.1.1";
    sha256 = "1mxdzwdarqhjfns6zbcz87409mxhj954in9qspazrw1m2h400sln";
  };

  buildInputs = [ pkgconfig protobuf zlib zip jdk libarchive unzip which makeWrapper ];

  installPhase = ''
    PROTOC=${protobuf}/bin/protoc bash compile.sh
    mkdir -p $out/bin $out/share
    cp -R output $out/share/bazel
    ln -s $out/share/bazel/bazel $out/bin/bazel
    wrapProgram $out/bin/bazel --set JAVA_HOME "${jdk.home}"
  '';

  meta = {
    homepage = http://github.com/google/bazel/;
    description = "Build tool that builds code quickly and reliably";
    license = stdenv.lib.licenses.asl20;
    maintainers = [ stdenv.lib.maintainers.philandstuff ];
  };
}

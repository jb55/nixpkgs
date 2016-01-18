{ stdenv, lua, fetchFromGitHub, fetchurl, which, llvm, clang, ncurses }:

let luajit_src = fetchurl {
  url = "http://luajit.org/download/LuaJIT-2.0.4.tar.gz";
  sha256 = "0zc0y7p6nx1c0pp4nhgbdgjljpfxsb5kgwp4ysz22l1p2bms83v2";
};
in stdenv.mkDerivation rec {
  name = "terra-git-${version}";
  version = "2016-01-06";

  src = fetchFromGitHub {
    owner = "zdevito";
    repo = "terra";
    rev = "914cb98b8adcd50b2ec8205ef5d6914d3547e281";
    sha256 = "1q0dm9gkx2lh2d2sfgly6j5nw32qigmlj3phdvjp26bz99cvxq46";
  };

  patchPhase = ''
    substituteInPlace Makefile --replace \
      '-lcurses' '-lncurses'
  '';

  configurePhase = ''
    mkdir -p build
    cp ${luajit_src} build/LuaJIT-2.0.4.tar.gz
    ls build
  '';

  installPhase = ''
    mkdir -p $out
    cp -r "release/"* $out
  '';

  buildInputs = [ which lua llvm clang ncurses ];

  meta = with stdenv.lib; {
    description = "A low-level counterpart to Lua";
    homepage = "https://github.com/zdevito/terra";
    maintainers = with maintainers; [ jb55 ];
    license = licenses.mit;
  };
}

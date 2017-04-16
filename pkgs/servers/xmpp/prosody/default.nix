{ stdenv, fetchurl, libidn, openssl, makeWrapper, fetchhg
, lua5, luasocket, luasec, luaexpat, luafilesystem, luabitop, luaevent ? null, luazlib ? null
, withLibevent ? true, withZlib ? true, extraModules ? [] }:

assert withLibevent -> luaevent != null;
assert withZlib -> luazlib != null;

with stdenv.lib;

let
  libs        = [ luasocket luasec luaexpat luafilesystem luabitop ]
                ++ optional withLibevent luaevent
                ++ optional withZlib luazlib;
  getPath     = lib : type : "${lib}/lib/lua/${lua5.luaversion}/?.${type};${lib}/share/lua/${lua5.luaversion}/?.${type}";
  getLuaPath  = lib : getPath lib "lua";
  getLuaCPath = lib : getPath lib "so";
  luaPath     = concatStringsSep ";" (map getLuaPath  libs);
  luaCPath    = concatStringsSep ";" (map getLuaCPath libs);
  modLine = mod:
    "cp $communityModules/mod_${mod}/mod_${mod}.lua $out/lib/prosody/modules/";

in

stdenv.mkDerivation rec {
  version = "0.9.12";
  name = "prosody-${version}";

  src = fetchurl {
    url = "http://prosody.im/downloads/source/${name}.tar.gz";
    sha256 = "139yxqpinajl32ryrybvilh54ddb1q6s0ajjhlcs4a0rnwia6n8s";
  };

  communityModules = fetchhg {
    url = "https://hg.prosody.im/prosody-modules";
    rev = "785465f8af3d";
    sha256 = "0rf7l293qc0d31djqz27zq9sm869n1bwhmxg9ikg1w0lw7k3v5z5";
  };

  buildInputs = [ lua5 luasocket luasec luaexpat luabitop libidn openssl makeWrapper ]
                ++ optional withLibevent luaevent
                ++ optional withZlib luazlib;

  configureFlags = [
    "--ostype=linux"
    "--with-lua-include=${lua5}/include"
    "--with-lua=${lua5}"
  ];

  postInstall = ''
      ${concatStringsSep "\n" (map modLine extraModules)}
      wrapProgram $out/bin/prosody \
        --set LUA_PATH '${luaPath};' \
        --set LUA_CPATH '${luaCPath};'
      wrapProgram $out/bin/prosodyctl \
        --add-flags '--config "/etc/prosody/prosody.cfg.lua"' \
        --set LUA_PATH '${luaPath};' \
        --set LUA_CPATH '${luaCPath};'
    '';

  meta = {
    description = "Open-source XMPP application server written in Lua";
    license = licenses.mit;
    homepage = http://www.prosody.im;
    platforms = platforms.linux;
    maintainers = [ maintainers.flosse ];
  };
}

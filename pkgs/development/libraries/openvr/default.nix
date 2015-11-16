{ stdenv, fetchFromGitHub, SDL2, mesa, steamVrHash }:

let
  deps = [
    stdenv.cc.libc
    stdenv.cc.cc
    SDL2
    mesa
  ];
  libPath = stdenv.lib.makeLibraryPath deps + ":${stdenv.cc.cc}/lib64";
  patchLib = x: "patchelf --set-rpath ${libPath} ${x}";
  # steamvr = stdenv.mkDerivation {
  #   name = "steamvr"

  #   src = requireFile {
  #     name = "SteamVR.tar"
  #     message = ''
  #       Unfortunately, we may not package the SteamVR runtime automatically.
  #       Please download SteamVR in Steam under Tools, then goto

  #         ~/.local/share/Steam/steamapps/common

  #       and add it to the Nix store using

  #         tar -cf SteamVR.tar SteamVR
  #         nix-prefetch-url 'file://SteamVR.tar'

  #       in your .nixpkgs/config.nix, add:

  #         openvr.steamVrHash = "<SteamVR.tar sha256sum>"
  #     '';
  #     sha256=steamVrHash;
  #   }
  # }

in stdenv.mkDerivation rec {
  name = "openvr-${version}";
  version = "0.9.11";

  src = fetchFromGitHub {
    rev    = "15078d84421d998404401de4e31e605fcefedb72";
    owner  = "ChristophHaag";
    repo   = "openvr";
    sha256 = "0lfwb8wi2il9cghap3dy2ml7i1cxzmlb9q8i3693shagj7l6svwy";
  };

  dontStrip = true;
  buildPhase = "true";

  installPhase = ''
    mkdir -p $out/{lib,include,share}
    # mkdir -p $HOME/.local/share/openvr/logs

    cp headers/* $out/include
    cp lib/linux64/libopenvr_api.so $out/lib/libopenvr.so

    ${patchLib "$out/lib/libopenvr.so"}

    cat << EOF > $out/share/openvrpaths.vrpath
    {
      "runtime" : [ "$out/lib/runtime" ],
      "config" : [ "$out/share/config" ],
      "log" : [ "~/.local/share/openvr/logs" ]
    }
    EOF

  '';

  meta = with stdenv.lib; {
    description = "Valve's VR abstraction library";
    homepage = "https://github.com/ValveSoftware/openvr";
    maintainers = with maintainers; [ jb55 ];
    license = licenses.unfreeRedistributableFirmware;
  };
}

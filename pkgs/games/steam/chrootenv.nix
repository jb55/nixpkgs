{ lib, buildFHSUserEnv
, withRuntime ? false
, withJava ? false
, withPrimus ? false
}:

buildFHSUserEnv {
  name = "steam";

  targetPkgs = pkgs:
    [ pkgs.steam-original
      # Errors in output without those
      pkgs.pciutils
      pkgs.python2
      # Games' dependencies
      pkgs.xlibs.xrandr
      pkgs.which
    ]
    ++ lib.optional withJava pkgs.jdk
    ++ lib.optional withPrimus pkgs.primus
    ;

  multiPkgs = pkgs: [
      # These are required by steam with proper errors
      pkgs.xlibs.libXcomposite
      pkgs.xlibs.libXtst
      pkgs.xlibs.libXrandr
      pkgs.xlibs.libXext
      pkgs.xlibs.libX11
      pkgs.xlibs.libXfixes

      pkgs.glib
      pkgs.gtk2
      pkgs.bzip2
      pkgs.zlib
      pkgs.libpulseaudio
      pkgs.gdk_pixbuf

      # Not formally in runtime but needed by some games
      pkgs.gst_all_1.gstreamer
      pkgs.gst_all_1.gst-plugins-ugly
    ] ++ lib.optionals withRuntime [
      pkgs.SDL
      pkgs.SDL2
      pkgs.SDL2_image
      pkgs.SDL2_mixer
      pkgs.SDL2_net
      pkgs.SDL2_ttf
      pkgs.SDL_image
      pkgs.SDL_mixer
      pkgs.SDL_ttf
      pkgs.alsaLib
      pkgs.atk
      pkgs.cairo
      pkgs.cups
      pkgs.curl
      pkgs.dbus
      pkgs.dbus_glib
      pkgs.expat
      pkgs.flac
      pkgs.fontconfig
      pkgs.freeglut
      pkgs.freetype
      pkgs.glew110
      pkgs.gnome2.GConf
      pkgs.gst_plugins_base
      pkgs.gstreamer
      pkgs.libav
      pkgs.libcap
      pkgs.libdrm
      pkgs.libidn
      pkgs.libjpeg
      pkgs.libmikmod
      pkgs.libogg
      pkgs.libpng12
      pkgs.libsamplerate
      pkgs.libtheora
      pkgs.libusb1
      pkgs.libuuid
      pkgs.libvorbis
      pkgs.mesa_glu
      pkgs.networkmanager098
      pkgs.nspr
      pkgs.nss
      pkgs.openal
      pkgs.openalSoft
      pkgs.openssl
      pkgs.pango
      pkgs.pixman
      pkgs.speex
      pkgs.udev182
      pkgs.xlibs.libICE
      pkgs.xlibs.libSM
      pkgs.xlibs.libXScrnSaver
      pkgs.xlibs.libXcursor
      pkgs.xlibs.libXdamage
      pkgs.xlibs.libXi
      pkgs.xlibs.libXinerama
      pkgs.xlibs.libXmu
      pkgs.xlibs.libXrender
      pkgs.xlibs.libpciaccess
      pkgs.xlibs.libxcb
    ];

  extraBuildCommands = ''
    [ -d lib64 ] && mv lib64/steam lib

    # FIXME: maybe we should replace this with proper libcurl-gnutls
    ( cd lib; ln -s libcurl.so.4 libcurl-gnutls.so.4 )
    [ -d lib64 ] && ( cd lib64; ln -s libcurl.so.4 libcurl-gnutls.so.4 )
  '';

  profile = if withRuntime then ''
    export STEAM_RUNTIME=0
  '' else ''
    # Ugly workaround for https://github.com/ValveSoftware/steam-for-linux/issues/3504
    export LD_PRELOAD=/lib32/libpulse.so:/lib64/libpulse.so:/lib32/libasound.so:/lib64/libasound.so:$LD_PRELOAD
    # Another one for https://github.com/ValveSoftware/steam-for-linux/issues/3801
    export LD_PRELOAD=/lib32/libstdc++.so:/lib64/libstdc++.so:$LD_PRELOAD
  '';

  runScript = "steam";
}

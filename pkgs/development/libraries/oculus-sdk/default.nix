{ stdenv, fetchFromGitHub, fetchurl, cmake, mesa, mesa_glu, libXrandr, libX11, udev,
  qt5, libXext, libXrender, makeWrapper }:

# source: https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=oculus-rift-sdk-jherico-git

let realVer = "0.5.0.1";
    deps = [
      stdenv.cc.libc
      stdenv.cc.cc
      mesa
      udev
      libXrandr
      libXrender
      libXext
      qt5.base
      libX11
    ];
    libPath = stdenv.lib.makeLibraryPath deps + ":${stdenv.cc.cc}/lib64";
    patchLib = x: "patchelf --set-rpath ${libPath} ${x}";
    wrapProg = x: "wrapProgram ${x} --prefix LD_LIBRARY_PATH : ${libPath}";
in stdenv.mkDerivation rec {
  name = "oculus-sdk-git-${version}";
  version = "2015-04-29";

  src = fetchFromGitHub {
    rev    = "cbf6f96b8083597de500d4110de0ed92f62c2a83";
    owner  = "jherico";
    repo   = "OculusSDK";
    sha256 = "0f5p6jcnjsa5hps8v5ir8ad5xwv5l3baw0vfym7xlw9kdahnq73d";
  };

  dontStrip = true;
  buildInputs = [ cmake mesa mesa_glu libXrandr libX11 libXrender libXext udev
                  makeWrapper ];

  buildPhase = ''
    cd ..
    rm -rf build
    mkdir -p build
    srcdir="$PWD"
    cd build

    mk () {
      [[ $1 == "STATIC" ]] && REP="SHARED / STATIC" || REP="STATIC / SHARED"
      sed -i "s/ $REP /g" $srcdir/LibOVR/CMakeLists.txt
      cmake -DCMAKE_INSTALL_PREFIX=$out/ -DCMAKE_BUILD_TYPE=$2 -DOVR_USE_SHIM=$3 -DCMAKE_CXX_FLAGS="-lX11 -lGL" $srcdir
      # TODO remove j0
      make -j8
    }

    # 64 bit STATIC SHIM RELEASE library
    mk "STATIC" "Release" "1"

    # 64 bit SHARED RELEASE library
    mk "SHARED" "Release" "0"

    # 64 bit STATIC SHIM DEBUG library
    mk "STATIC" "Debug" "1"

    # 64 bit SHARED DEBUG library
    mk "SHARED" "Debug" "0"
  '';

  riftConfigUtil = fetchurl {
    url = "http://haagch.frickel.club/files/ovr_sdk_linux_${realVer}/Tools/RiftConfigUtil/Bin/Linux/x86_64/ReleaseStatic/RiftConfigUtil";
    sha256 = "18dak8lgrpmxaz657sgsimj606lyssmwlcqvc76gw5irbv0v4snr";
  };

  # desktopItem = makeDesktopItem {
  #   name = "ovrd";
  #   exec = "ovrd";
  #   comment = "Oculus Rift Daemon";
  #   desktopName = "Oculus Daemon";
  #   genericName = "Oculus Rift Daemon";
  #   categories = "System;";
  # };

  installPhase = ''
    echo "huh"
    srcdir="$PWD/.."
    echo "Wut"
    oculusv="$realVer" #meh: $(cat LibOVR/Include/OVR_Version.h | sed -n 's/.*#define OVR_VERSION_STRING "\(.*\)"/\1/p')

    mkdir -p "$out/lib"
    mkdir -p "$out/bin"
    mkdir -p "$out/include"
    mkdir -p "$out/share/OculusConfigUtil"

    # TODO: patchelf me
    install -m 755 "${riftConfigUtil}" "$out/bin/OculusConfigUtil"
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/OculusConfigUtil
    ${wrapProg "$out/bin/OculusConfigUtil"}

    echo "1"

    cp "output/libovr.a" "$out/lib/libOVR.a"
    cp "output/libovr.so" "$out/lib/libOVRRT64_0.so.5.0.1"
    cp "output/libovrd.a" "$out/lib/libOVRd.a"
    cp "output/libovrd.so" "$out/lib/libOVRdRT64_0.so.5.0.1"

    ln -s libOVRRT64_0.so.5.0.1 $out/lib/libOVRRT64_0.so.5
    ln -s libOVRdRT64_0.so.5.0.1 $out/lib/libOVRdRT64_0.so.5

    echo "2"

    #library was previously named libovr
    ln -s $out/lib/libOVRRT64_0.so.5.0.1 $out/lib/libovr.so
    ln -s $out/lib/libOVR.a $out/lib/libovr.a
    ln -s $out/lib/libOVRdRT64_0.so.5.0.1 $out/lib/libovrd.so
    ln -s $out/lib/libOVRd.a $out/lib/libovrd.a

    # To be sure, these names too
    ln -s $out/lib/libovr.so $out/lib/libOculusVR.so
    ln -s $out/lib/libovr.a $out/lib/libOculusVR.a

    echo "3"

    cp -rd "$srcdir/LibOVR/Include"/* $out/include
    cp -rd "$srcdir/LibOVRKernel/Src"/* $out/include

    #this is just the whole library source code. You never know.
    cp -rd "$srcdir/LibOVRKernel" "$out/include/"
    cp -rd "$srcdir/LibOVR" "$out/include/"

    #Grrr... https://github.com/Germanunkol/OgreOculusSample/blob/3ec4b9f9412db21455a324eb7d6d8dd82e2cddbf/cmake/FindOculusSDK.cmake#L36-L37
    cp -rd "$out/include/LibOVR/Include/"*.h "$out/include/LibOVR/Src/"
    cp -rd "$out/include/LibOVRKernel/Src/Kernel/" "$out/include/LibOVR/Include/"
    cp -rd "$out/include/LibOVR/Include/Extras/"*.h "$out/include/LibOVR/Include/Kernel/"
    cp -rd "$out/include/LibOVR/Include/Extras/"*.h "$out/include/LibOVR/Include/"

    #TODO: Bindings

    # install -m755 "$srcdir/OculusConfigUtil.sh" "$out/bin/OculusConfigUtil"

    echo "4"

    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/ovrd
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/ovrd
    ${wrapProg "$out/bin/ovrd"}
    echo "udev: ${udev}/lib"
    # patchelf --set-rpath "${udev}/lib" $out/bin/ovrd

    echo "5"
    #TODO: make systemd service
#     install -d "$out/etc/xdg/autostart"
#     echo "[Desktop Entry]
# Type=Application
# Exec=/usr/bin/ovrd" > "$pkgdir/etc/xdg/autostart/ovrd.desktop"
  '';

  meta = with stdenv.lib; {
    description = "Oculus Rift SDK community version";
    homepage = "https://github.com/jherico/OculusSDK";
    maintainers = with maintainers; [ jb55 ];
    license = licenses.unfreeRedistributableFirmware;
  };
}

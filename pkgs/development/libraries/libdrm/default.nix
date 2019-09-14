{ stdenv, lib, fetchgit, pkgconfig, meson, ninja, libpthreadstubs, libpciaccess
, withValgrind ? valgrind-light.meta.available, valgrind-light
}:

stdenv.mkDerivation rec {
  pname = "libdrm";
  version = "git-2019-08-30";

  src = fetchgit {
    url = "https://gitlab.freedesktop.org/mesa/drm";
    rev = "10cd9c3da848e131db0eb8e1f9cf88fe4d85e703";
    sha256 = "1bz4iqa8j781hq5sf2nn9awyss87yljn6i6m7zrpzfzh8hasnlhn";
  };

  outputs = [ "out" "dev" "bin" ];

  nativeBuildInputs = [ pkgconfig meson ninja ];
  buildInputs = [ libpthreadstubs libpciaccess ]
    ++ lib.optional withValgrind valgrind-light;

  patches = [ ./cross-build-nm-path.patch ];

  postPatch = ''
    for a in */*-symbol-check ; do
      patchShebangs $a
    done
  '';

  mesonFlags = [
    "-Dnm-path=${stdenv.cc.targetPrefix}nm"
    "-Dinstall-test-programs=true"
    "-Domap=true"
  ] ++ lib.optionals (stdenv.isAarch32 || stdenv.isAarch64) [
    "-Dtegra=true"
    "-Detnaviv=true"
  ] ++ lib.optional (stdenv.hostPlatform != stdenv.buildPlatform) "-Dintel=false";

  enableParallelBuilding = true;

  meta = {
    homepage = https://dri.freedesktop.org/libdrm/;
    description = "Library for accessing the kernel's Direct Rendering Manager";
    license = "bsd";
    platforms = lib.platforms.unix;
  };
}

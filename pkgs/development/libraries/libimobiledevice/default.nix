{ stdenv, fetchurl, python, pkgconfig, usbmuxd, glib, libgcrypt,
  libtasn1, libplist, readline, libusbmuxd, openssl }:

stdenv.mkDerivation rec {
  name = "libimobiledevice-1.2.0";

  nativeBuildInputs = [ python libplist.swig pkgconfig ];
  buildInputs = [ readline ];
  propagatedBuildInputs = [ libusbmuxd glib libgcrypt libtasn1 libplist openssl ];

  patchPhase = ''sed -e 's@1\.3\.21@@' -i configure'';
  passthru.swig = libplist.swig;

  src = fetchurl {
    url = "${meta.homepage}/downloads/${name}.tar.bz2";
    sha256 = "0dqhy4qwj30mw8pwckvjmgnj1qqrh6p8c6jknmhvylshhzh0ssvq";
  };

  meta = {
    homepage = http://www.libimobiledevice.org;
    description = "A software library that talks the protocols to support iPhone®, iPod Touch® and iPad® devices on Linux";
    longDescription = ''
      libimobiledevice is a software library that talks the protocols to support
      iPhone®, iPod Touch® and iPad® devices on Linux. Unlike other projects, it
      does not depend on using any existing proprietary libraries and does not
      require jailbreaking. It allows other software to easily access the
      device's filesystem, retrieve information about the device and it's
      internals, backup/restore the device, manage SpringBoard® icons, manage
      installed applications, retrieve addressbook/calendars/notes and bookmarks
      and synchronize music and video to the device. The library is in
      development since August 2007 with the goal to bring support for these
      devices to the Linux Desktop.'';
    inherit (usbmuxd.meta) platforms maintainers;
  };
}

{ lib, stdenv, fetchurl, python, pkgconfig, perl, libxslt, docbook_xsl
, fetchpatch
, fetchpgpkey
, verifySignatureHook
, docbook_xml_dtd_42, docbook_xml_dtd_45, readline, talloc
, popt, iniparser, libbsd, libarchive, libiconv, gettext
, krb5Full, zlib, openldap, cups, pam, avahi, acl, libaio, fam, libceph, glusterfs
, gnutls, ncurses, libunwind, systemd, jansson, lmdb, gpgme

, enableLDAP ? false
, enablePrinting ? false
, enableMDNS ? false
, enableDomainController ? false
, enableRegedit ? true
, enableCephFS ? false
, enableGlusterFS ? false
, enableAcl ? (!stdenv.isDarwin)
, enablePam ? (!stdenv.isDarwin)
}:

with lib;

stdenv.mkDerivation rec {
  name = "samba-${version}";
  version = "4.10.2";

  src = fetchurl {
    url = "mirror://samba/pub/samba/stable/${name}.tar.gz";
    sha256 = "112yizx9cpjhi8c7mh9znqg0c9dkj3383hwr8dhgpykl3g2zv347";
  };

  srcSignature = fetchurl {
    url = "mirror://samba/pub/samba/stable/${name}.tar.asc";
    sha256 = "0wpcbwbs1bj1y0amhn0z29v55f2hhmzc5p8n7sbwg9kaf0hc5mz5";
  };
  signatureUncompressed = true;

  signaturePublicKey = fetchpgpkey {
    url = https://download.samba.org/pub/samba/samba-pubkey.asc;
    sha256 = "1fndhq0c34va34z137gvsl9gpwjv30b06makfx8cq5vrmgiax1x1";
    fingerprint = "52FBC0B86D954B0843324CDC6F33915B6568B7EA";
  };

  nativeBuildInputs = [ verifySignatureHook ];

  outputs = [ "out" "dev" "man" ];

  patches =
    [ ./4.x-no-persistent-install.patch
      ./patch-source3__libads__kerberos_keytab.c.patch
      ./4.x-no-persistent-install-dynconfig.patch
      ./4.x-fix-makeflags-parsing.patch
    ];


  buildInputs =
    [ python pkgconfig perl libxslt docbook_xsl docbook_xml_dtd_42 /*
      docbook_xml_dtd_45 */ readline popt iniparser jansson
      libbsd libarchive zlib fam libiconv gettext libunwind krb5Full
    ]
    ++ optionals stdenv.isLinux [ libaio systemd ]
    ++ optional enableLDAP openldap
    ++ optional (enablePrinting && stdenv.isLinux) cups
    ++ optional enableMDNS avahi
    ++ optionals enableDomainController [ gnutls gpgme lmdb ]
    ++ optional enableRegedit ncurses
    ++ optional (enableCephFS && stdenv.isLinux) libceph
    ++ optional (enableGlusterFS && stdenv.isLinux) glusterfs
    ++ optional enableAcl acl
    ++ optional enablePam pam;

  postPatch = ''
    # Removes absolute paths in scripts
    sed -i 's,/sbin/,,g' ctdb/config/functions

    # Fix the XML Catalog Paths
    sed -i "s,\(XML_CATALOG_FILES=\"\),\1$XML_CATALOG_FILES ,g" buildtools/wafsamba/wafsamba.py

    patchShebangs ./buildtools/bin
  '';

  configureFlags =
    [ "--with-static-modules=NONE"
      "--with-shared-modules=ALL"
      "--with-system-mitkrb5"
      "--with-system-mitkdc" "${krb5Full}"
      "--enable-fhs"
      "--sysconfdir=/etc"
      "--localstatedir=/var"
    ]
    ++ [(if enableDomainController
         then "--with-experimental-mit-ad-dc"
         else "--without-ad-dc")]
    ++ optionals (!enableLDAP) [ "--without-ldap" "--without-ads" ]
    ++ optional (!enableAcl) "--without-acl-support"
    ++ optional (!enablePam) "--without-pam";

  preBuild = ''
      export MAKEFLAGS="-j $NIX_BUILD_CORES"
  '';

  # Some libraries don't have /lib/samba in RPATH but need it.
  # Use find -type f -executable -exec echo {} \; -exec sh -c 'ldd {} | grep "not found"' \;
  # Looks like a bug in installer scripts.
  postFixup = ''
    export SAMBA_LIBS="$(find $out -type f -name \*.so -exec dirname {} \; | sort | uniq)"
    read -r -d "" SCRIPT << EOF || true
    [ -z "\$SAMBA_LIBS" ] && exit 1;
    BIN='{}';
    OLD_LIBS="\$(patchelf --print-rpath "\$BIN" 2>/dev/null | tr ':' '\n')";
    ALL_LIBS="\$(echo -e "\$SAMBA_LIBS\n\$OLD_LIBS" | sort | uniq | tr '\n' ':')";
    patchelf --set-rpath "\$ALL_LIBS" "\$BIN" 2>/dev/null || exit $?;
    patchelf --shrink-rpath "\$BIN";
    EOF
    find $out -type f -name \*.so -exec $SHELL -c "$SCRIPT" \;
  '';

  meta = with stdenv.lib; {
    homepage = https://www.samba.org/;
    description = "The standard Windows interoperability suite of programs for Linux and Unix";
    license = licenses.gpl3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ aneeshusa ];
  };
}

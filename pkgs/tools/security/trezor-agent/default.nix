{ buildPythonPackage, qtbase, stdenv, fetchFromGitHub,
  trezor, libagent, lib, pinentry_gtk2
}:

buildPythonPackage rec {
  name = "${pname}-${version}";
  pname = "trezor_agent";
  version = "0.13.1";

  src = "${fetchFromGitHub {
    repo = "trezor-agent";
    owner = "romanz";
    rev = "v${version}";
    sha256 = "0q99vbfd3h85s8rnjipnmldixabqmmlk5w9karv6f0rhyi54f4zv";
  }}/agents/trezor";

  propagatedBuildInputs = [ trezor libagent  ];

  postFixup = ''
    # fix for qt pinentry in non-tty environments such as systemd services
    wrapProgram $out/bin/trezor-gpg-agent \
      --set QT_QPA_PLATFORM_PLUGIN_PATH "${qtbase.bin}/lib/qt-*/plugins/platforms/" \
      --prefix PATH : ${lib.makeBinPath [ pinentry_gtk2 ]}

    wrapProgram $out/bin/trezor-gpg \
      --prefix PATH : ${lib.makeBinPath [ pinentry_gtk2 ]}
  '';

  meta = with stdenv.lib; {
    description = "Using Trezor as hardware SSH agent";
    homepage = https://github.com/romanz/trezor-agent;
    license = licenses.gpl3;
    maintainers = with maintainers; [ jb55 np ];
  };
}

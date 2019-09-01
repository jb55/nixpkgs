{ stdenv, lib, fetchFromGitHub
, cmake, opencascade, boost, icu, pkgconfig
}:

let cflag = flag: b: "-D${flag}=${if b then "ON" else "OFF"}";
in
stdenv.mkDerivation rec {
  pname = "IfcOpenShell";
  version = "git-ef7eee411b29a82b";

  src = fetchFromGitHub {
    owner  = name;
    repo   = name;
    rev    = "ef7eee411b29a82b55e3eec308baa20b8d3987c6";
    sha256 = "0q50dyn2lhmjbm04fws19p9h5siv1xan4qqlclk8zsz6hdaw69cn";
  };

  installFlags = "PREFIX=$(out)";

  enableParallelBuilding = true;

  cmakeFlags = [ (cflag "COLLADA_SUPPORT" false)
                 (cflag "BUILD_IFCPYTHON" false)
                 (cflag "ENABLE_BUILD_OPTIMIZATIONS" true)
                 "-DOCC_INCLUDE_DIR=${opencascade}/include/oce"
                 "-DOCC_LIBRARY_DIR=${opencascade}/lib"
                 "-DICU_INCLUDE_DIR=${icu}/include"
                 "-DICU_LIBRARY_DIR=${icu}/lib"
               ];

  configurePhase = ''
    cd cmake
    cmakeConfigurePhase
  '';

  nativeBuildInputs = [ cmake pkgconfig ];

  buildInputs = [ opencascade boost icu ];

  meta = with stdenv.lib; {
    description = "IFC to Polygon converter";
    homepage = "https://github.com/IfcOpenShell/IfcOpenShell";
    maintainers = with maintainers; [ jb55 ];
    license = licenses.lgpl;
  };
}

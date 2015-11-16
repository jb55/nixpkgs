
{ stdenv }:

stdenv.mkDerivation {
  name = "oculus-udev";
  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p "$out/etc/udev/rules.d/";
    cat > "$out/etc/udev/rules.d/83-oculus.rules" << EOF
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2833", MODE="0666"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="2833", MODE="0666"
    EOF
  '';

  meta = {
    description = "Udev rules for Oculus Rift";
    platforms = stdenv.lib.platforms.linux;
  };
}

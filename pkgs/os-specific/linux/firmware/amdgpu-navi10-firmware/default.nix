{ stdenv, fetchurl }:
let
  fetchbin = {name, sha256}: fetchurl {
    url = "https://people.freedesktop.org/~agd5f/radeon_ucode/navi10/${name}";
    inherit sha256;
  };
  firmware = [
    {name = "navi10_asd.bin"; sha256 = "0w8wwnsc67p069pyygacw1zqp626pg0yzv76y65wvxsnz51dnjq0";}
    {name = "navi10_ce.bin"; sha256 = "0crs6v41nsjy85ih229wfdyvqfwfaza91j4kdjil6lnhwf1yn6yg";}
    {name = "navi10_gpu_info.bin"; sha256 = "159k9xdsrgl9ly03wd14yr3qm4cnhdn4a2kwc1ciphm584r8vkii";}
    {name = "navi10_me.bin"; sha256 = "0fafk3vac2l0p6ckjh0r6jdfs0bdv0qk6bmrh50q4d4d246jmksp";}
    {name = "navi10_mec.bin"; sha256 = "1wg3nbmi6ssg6z0gjgapi12s7dc2pa5w19lm94q3pqaq6qjyx7h9";}
    {name = "navi10_mec2.bin"; sha256 = "1wg3nbmi6ssg6z0gjgapi12s7dc2pa5w19lm94q3pqaq6qjyx7h9";}
    {name = "navi10_pfp.bin"; sha256 = "112mwnzdkabwnmbs0icv7g4sy0iglxypvhr7xw8c4g3mk5rh2svc";}
    {name = "navi10_rlc.bin"; sha256 = "04haf0j1r5z8fmg9d8bxrs96dqcg8ck3n95c32r5fl5qrzs0sjfs";}
    {name = "navi10_sdma.bin"; sha256 = "06b1lmvj5xky3zxyagyfazalmi6ry42jms20926cvahz37mbzpq7";}
    {name = "navi10_sdma1.bin"; sha256 = "06b1lmvj5xky3zxyagyfazalmi6ry42jms20926cvahz37mbzpq7";}
    {name = "navi10_smc.bin"; sha256 = "1d5g8kjsdzi4wkyspr4ngfax9wigxh9hl28krmdfsfv60jw5ij93";}
    {name = "navi10_sos.bin"; sha256 = "1b8g4zcixcpqfmck0qjipvw13q6xjpwmjp4cymlaghv8qv9rbp5z";}
    {name = "navi10_vcn.bin"; sha256 = "191iv498m2rpwb37050kdfaswningcf0qz3nv6d2a9mnihrgbkif";}
  ];

  firmwareDir = "$out/lib/firmware/amdgpu";
  installFirmware = {name, bin}: "install -D -pm644 ${bin} ${firmwareDir}/${name}";
  srcs = map fetchbin firmware;
  namedSrcs = stdenv.lib.zipListsWith ({ name, ... }: bin: { inherit name bin; }) firmware srcs;
in
stdenv.mkDerivation {
  pname = "amdgpu-navi10-firmware";
  version = "2019-09-13";

  inherit srcs;

  sourceRoot = ".";

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p ${firmwareDir}
    ${stdenv.lib.concatStringsSep "\n" (map installFirmware namedSrcs)}
  '';

  meta = with stdenv.lib; {
    description = "Firmware for navi10 GPUs";
    homepage = "https://people.freedesktop.org/~agd5f/radeon_ucode/navi10/";
    license = licenses.unfreeRedistributableFirmware;
    maintainers = with maintainers; [ jb55 ];
    platforms = with platforms; linux;
  };
}

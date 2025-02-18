{ rustPlatform, lib, openssl, pkg-config, fetchFromGitHub }:
rustPlatform.buildRustPackage rec {
  pname = "nostcat";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "blakejakopovic";
    repo = "nostcat";
    rev = "v${version}";
    hash = "sha256-6sNRQ0a7SesW9H9U7QmVqmngzdIYC5JGgSo8AOp3sT0=";
  };

  buildInputs = [ openssl ];
  nativeBuildInputs = [ pkg-config ];

  cargoHash = "sha256-G0EnsZ0wGhHdoXJ+R1/39l8DA07cspRGNuhbUFnAeoI=";

  doInstallCheck = true;

  meta = with lib; {
    description = "Command-line utility to query nostr relays";
    homepage = "https://github.com/blakejakopovic/nostcat";
    #changelog = "https://github.com/blakejakopovic/nostcat/raw/v${version}/CHANGELOG.md";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ jb55 ];
    platforms = platforms.all;
    mainProgram = "nostcat";
  };
}

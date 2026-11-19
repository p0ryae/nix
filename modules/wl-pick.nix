# wl-pick.nix
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  fontconfig,
  makeWrapper,
}:

rustPlatform.buildRustPackage {
  pname = "wl-pick";
  version = "unstable-2026-11-19";

  src = fetchFromGitHub {
    owner = "mil-ad";
    repo = "wl-pick";
    rev = "93dda58852f3686c70a718325679e21262413aee";
    hash = "sha256-JQdRmRt+Hh34dKqP/bZYBpmWY3cIdw6y3Q9bpfJyo5A=";
  };

  cargoHash = "sha256-W/CjIZCQpBi6f0gPHata45/sat3LMev6S1XVAj6k8v8=";

  doCheck = false;

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];
  buildInputs = [ fontconfig ];

  meta = {
    description = "Window switcher with live previews for wlroots compositors";
    homepage = "https://github.com/mil-ad/wl-pick";
    license = lib.licenses.mit;
    mainProgram = "wl-pick";
  };
}

{
  msolve,
  fetchFromGitHub,
}:

msolve.overrideAttrs {
  version = "0.9.4-unstable-2026-02-23";
  src = fetchFromGitHub {
    owner = "algebraic-solving";
    repo = "msolve";
    rev = "2e43f3f91c4b8c9b9116a248b0a74f4e49446b80";
    hash = "sha256-Izq61NZOc76cnrjLKCmu1rbe9G4Rb2cvI0Hp1y1kOPc=";
  };
}

{
  msolve,
  fetchFromGitHub,
}:

msolve.overrideAttrs {
  version = "0.9.4-unstable-2026-03-08";
  src = fetchFromGitHub {
    owner = "algebraic-solving";
    repo = "msolve";
    rev = "ff6fb15ac785376a0d62f4820d5d87526a2e2e84";
    hash = "sha256-gjiIHFGppriNgHfSPIB5WAOEO5nBLcL8NqS+K51McoM=";
  };
}

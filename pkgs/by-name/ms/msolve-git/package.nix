{
  msolve,
  fetchFromGitHub,
}:

msolve.overrideAttrs {
  version = "0.9.5-unstable-2026-04-12";
  src = fetchFromGitHub {
    owner = "algebraic-solving";
    repo = "msolve";
    rev = "573a6e83913cfe29e7a757a79715091efc4f76bc";
    hash = "sha256-XuCMijmb25mdzylXTeToTRZxF03+RhMs5cICaLOGvPc=";
  };
}

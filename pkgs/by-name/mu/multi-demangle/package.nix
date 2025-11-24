{
  lib,
  fetchFromGitHub,
  python3Packages,
  rustPlatform,
}:

python3Packages.buildPythonPackage rec {
  pname = "multi-demangle";
  version = "1.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "AppThreat";
    repo = "multi-demangle";
    tag = "v${version}";
    hash = "sha256-COcYk6UpVD+Afg16LnS0zB/TVkktWcRidQQjcgyI1AY=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-jyEteyERAa/0WaqeYYjrDuX29l1F1vmjYfPVGq4KoIo=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  meta = {
    description = "Library to demangle symbols from various languages and compilers";
    changelog = "https://github.com/AppThreat/multi-demangle/releases/tag/${src.tag}";
    homepage = "https://github.com/AppThreat/multi-demangle";
    maintainers = with lib.maintainers; [ wegank ];
    license = lib.licenses.mit;
  };
}

{
  lib,
  stdenv,
  python3Packages,
  fetchPypi,
}:

let
  format = "wheel";
  system = stdenv.hostPlatform.system;
  platforms = {
    aarch64-darwin = "macosx_11_0_arm64";
    aarch64-linux = "manylinux_2_27_aarch64.manylinux_2_28_aarch64";
    x86_64-darwin = "macosx_10_12_x86_64";
    x86_64-linux = "manylinux_2_27_x86_64.manylinux_2_28_x86_64";
  };
  platform = platforms.${system} or (throw "Unsupported system: ${system}");
  hashes = {
    aarch64-darwin = "sha256-RezJPZ5tqP8jUp3APBKOzF9lJxVdwKEOwArKAgvNJQ8=";
    aarch64-linux = "sha256-8JweYAyucSk6ta6d3DCqVqhxRjg3oCDrI7JG+iAkxGI=";
    x86_64-darwin = "sha256-GBJv7SgRXvvnZ/w8tVjH67TSFbRDrI8AXHj6qvE+BRg=";
    x86_64-linux = "sha256-UIf80TNB9Sm1QEeSp04i9XDlDxfl6kyr6ckbHK90y/Q=";
  };
  hash = hashes.${system} or (throw "Unsupported system: ${system}");
in
python3Packages.buildPythonPackage rec {
  pname = "bids-validator-deno";
  version = "2.4.1";
  inherit format;

  src = fetchPypi {
    pname = "bids_validator_deno";
    inherit
      version
      format
      platform
      hash
      ;
  };

  meta = {
    description = "Validator for the Brain Imaging Data Structure";
    homepage = "https://github.com/bids-standard/bids-validator";
    changelog = "https://github.com/bids-standard/bids-validator/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wegank ];
  };
}

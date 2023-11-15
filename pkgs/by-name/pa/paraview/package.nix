{ paraview
, fetchFromGitLab
}:

paraview.overrideAttrs rec {
  version = "5.12.0-RC1";

  src = fetchFromGitLab {
    domain = "gitlab.kitware.com";
    owner = "paraview";
    repo = "paraview";
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-YCbtVEDKtDOmgSX0GHbDZH3pw19tXITQg/9LpaA7x58=";
  };
}

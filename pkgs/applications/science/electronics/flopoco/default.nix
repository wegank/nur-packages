{ lib
, stdenv
, fetchFromGitLab
, fetchpatch
, cmake
, installShellFiles
, bison
, boost
, flex
, gmp
, libxml2
, mpfi
, mpfr
, scalp
, sollya
, wcpg
}:

stdenv.mkDerivation rec {
  pname = "flopoco";
  version = "4.1.2";

  src = fetchFromGitLab {
    owner = pname;
    repo = pname;
    # flopoco-4.1.2 is not tagged on GitLab
    rev = "5f6886f55d3c74b547fb3d030a622a74b7dfed6e";
    sha256 = "sha256-ccafc81aTXC9M7MqsoNR2Qj2X6xIl4FxsTYHLFcEVPM=";
  };

  patches = [
    (fetchpatch {
      name = "fix-clang-error-sin-cos.patch";
      url = "https://gitlab.com/flopoco/flopoco/-/commit/de3aa60ad19333952c176c2a2e51f12653ca736b.patch";
      postFetch = ''
        substituteInPlace $out --replace 'FixSinCosCORDIC.hpp' 'CordicSinCos.hpp'
      '';
      sha256 = "sha256-BlamA/MZuuqqvGYto+jPeQPop6gwva0y394Odw8pdwg=";
    })
    (fetchpatch {
      name = "fix-clang-error-atan2.patch";
      url = "https://gitlab.com/flopoco/flopoco/-/commit/a3ffe2436c1b59ee0809b3772b74f2d43c6edb99.patch";
      sha256 = "sha256-dSYcufLHDL0p1V1ghmy6X6xse5f6mjUqckaVqLZnTaA=";
    })
  ];

  postPatch = lib.optionalString (stdenv.isDarwin && stdenv.isx86_64) ''
    substituteInPlace CMakeLists.txt --replace "-pg" ""
    substituteInPlace src/Apps/TaMaDi/CMakeLists.txt --replace "-pg" ""
  '';

  nativeBuildInputs = [
    cmake
    installShellFiles
  ];

  buildInputs = [
    bison
    boost
    flex
    gmp
    libxml2
    mpfi
    mpfr
    scalp
    sollya
    wcpg
  ];

  installPhase = ''
    ./flopoco BuildAutocomplete
    install -Dm755 flopoco $out/bin/flopoco
    cp bin* fp* ieee* longacc* $out/bin/
    installShellCompletion --bash flopoco_autocomplete
  '';

  meta = with lib; {
    description = "The FloPoCo arithmetic core generator";
    homepage = "http://flopoco.org";
    license = licenses.agpl3Plus;
    platforms = platforms.unix;
    maintainers = with maintainers; [ wegank ];
  };
}

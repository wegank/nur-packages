{ autoreconfHook
, check
, elfutils
, fetchFromGitHub
, flex
, lib
, libelf
, llvm
, pkg-config
, stdenv
, which
, zlib
}:

stdenv.mkDerivation rec {
  pname = "nvc";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "nickg";
    repo = "${pname}";
    rev = "r${version}";
    sha256 = "sha256-BtUMpT1MKRFGRlIbCEGo4OBZ/r9es1VRmJdgmk1oZFQ=";
  };

  nativeBuildInputs = [
    autoreconfHook
    check
    flex
    pkg-config
    which
  ];

  buildInputs = [
    llvm
    zlib
  ] ++ (if stdenv.isLinux then [
    elfutils
  ] else [
    libelf
  ]);

  # TODO: remove me on 1.7.0
  postPatch = lib.optionalString stdenv.isDarwin ''
    substituteInPlace test/regress/testlist.txt \
      --replace "vests22         normal" ""
    substituteInPlace test/dist.mk \
      --replace "test/regress/vests22.vhd" ""
  '';

  preConfigure = ''
    mkdir build
    cd build
  '';

  configureScript = "../configure";

  configureFlags = [
    "--enable-vhpi"
  ]
  # TODO: remove me on 1.7.0
  ++ lib.optionals (stdenv.isAarch64 && stdenv.isLinux) [
    "--disable-lto"
  ];

  doCheck = true;

  meta = with lib; {
    description = "VHDL compiler and simulator";
    homepage = "https://www.nickg.me.uk/nvc/";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
    # maintainers = with maintainers; [ wegank ];
  };
}

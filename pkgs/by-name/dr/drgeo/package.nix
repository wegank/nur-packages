{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, unzip
, alsa-lib
, cairo
, glib
, libICE
, libSM
, libX11
, libXext
, libXrender
, libpulseaudio
, libuuid
, nas
, pango
, sndio
}:

stdenv.mkDerivation rec {
  pname = "drgeo";
  version = "23.06";

  src = fetchurl {
    url = "https://launchpad.net/drgeo/trunk/${version}/+download/DrGeo-gnulinux-${version}a-beta.zip";
    hash = "sha256-ezqaJHS+xGYoLkS4whgVqBtak4Ueoh3RuPkEktD9/Nw=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    unzip
  ];

  buildInputs = [
    alsa-lib
    cairo
    glib
    libICE
    libSM
    libX11
    libXext
    libXrender
    libpulseaudio
    libuuid
    nas
    pango
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,opt/drgeo}
    cp -R * $out/opt/drgeo
    makeWrapper $out/opt/drgeo/DrGeo.sh $out/bin/drgeo

    sed -i "s#BIN=.*/lib#BIN=$out/opt/drgeo/VM/lib#" $out/opt/drgeo/VM/{bin/*,squeak}
    substituteInPlace $out/opt/drgeo/VM/{bin/*,squeak} \
      --replace "/usr/bin/ldd" "ldd" \
      --replace "/bin/fgrep" "fgrep"

    mkdir -p $out/lib
    ln -s ${sndio}/lib/libsndio.so $out/lib/libsndio.so.6.1

    runHook postInstall
  '';

  meta = with lib; {
    description = "A program to design and manipulate interactive geometric sketches";
    homepage = "https://www.gnu.org/software/dr-geo/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ wegank ];
    platforms = platforms.linux;
    broken = stdenv.isDarwin;
  };
}

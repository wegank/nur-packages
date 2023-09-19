{ lib
, stdenv
, fetchurl
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "esterel";
  version = "5.92";

  src = fetchurl {
    url = "https://download.tuxfamily.org/slitaz/sources/packages-stable/e/esterel-${version}.tgz";
    hash = "sha256-DJYu4tK4c0Zux+ZB/ap+qIOohmN1rFoOkgW/9OuGXcY=";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out
    mv -t $out bin include share

    runHook postInstall
  '';

  meta = with lib; {
    description = "A Synchronous Reactive Programming Language";
    homepage = "https://web.archive.org/web/20051210122115/http://www-sop.inria.fr/esterel.org/";
    license = licenses.unfree;
    maintainers = with maintainers; [ wegank ];
    platforms = platforms.linux;
  };
})

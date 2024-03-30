{
  godot_4,
  withDebug ? false,
  stdenv,
}:

let
  buildType = if withDebug then "debug" else "release";
in
(godot_4.override {
  withTarget = "template_${buildType}";
}).overrideAttrs
  (prevAttrs: {
    pname = "godot_4-export-templates";

    outputs = [ "out" ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/godot/templates/${prevAttrs.version}.stable
      cp bin/godot.*.template_${buildType}.* $out/share/godot/templates/${prevAttrs.version}.stable/linux_x11_${toString stdenv.hostPlatform.parsed.cpu.bits}_${buildType}

      runHook postInstall
    '';

    meta.description = prevAttrs.meta.description + " (export templates)";
  })

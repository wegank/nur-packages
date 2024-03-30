{
  lib,
  godot_4,
  withDebug ? false,
  stdenv,
}:

let
  buildType = if withDebug then "debug" else "release";
  template =
    {
      "arm7l-linux" = "linux_${buildType}.arm32";
      "aarch64-linux" = "linux_${buildType}.arm64";
      "x86_64-linux" = "linux_${buildType}.x86_64";
      "i686-linux" = "linux_${buildType}.x86_32";
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  templateVersion = lib.replaceStrings [ "-" ] [ "." ] godot_4.version;
in
(godot_4.override { withTarget = "template_${buildType}"; }).overrideAttrs (previousAttrs: {
  pname = "godot_4-export-templates";

  outputs = [ "out" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/godot/export_templates/${templateVersion}
    cp bin/godot.*.template_${buildType}.* $out/share/godot/export_templates/${templateVersion}/${template}

    runHook postInstall
  '';

  meta.description = previousAttrs.meta.description + " (export templates)";
  meta.broken = stdenv.isDarwin;
})

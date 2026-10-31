{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "scskiller";
  version = "1.4.2";

  src = fetchurl {
    url = "https://github.com/BlueHeisenberg/SCSKiller/releases/download/v${version}/SCSKiller-x86_64.AppImage";
    hash = "sha256-Iz+mhEQYXssusyv7XDjxkGwWNHWXIvx2C2XqxQTPoF0=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  # Self-contained .NET / Avalonia app; most runtime libs (fontconfig, X11,
  # GL, vulkan-loader, openssl) already come from the appimage FHS env.
  extraPkgs =
    pkgs: with pkgs; [
      icu
      lttng-ust_2_12
    ];

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/SCSKiller.App.desktop \
      $out/share/applications/scskiller.desktop
    install -Dm444 ${appimageContents}/SCSKiller.App.png \
      $out/share/icons/hicolor/256x256/apps/SCSKiller.App.png
    substituteInPlace $out/share/applications/scskiller.desktop \
      --replace-fail 'Exec=SCSKiller.Ui' 'Exec=${pname}'
  '';

  meta = {
    description = "SCSKiller";
    homepage = "https://github.com/BlueHeisenberg/SCSKiller";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}

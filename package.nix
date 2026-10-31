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

  # SCSKiller keeps its named-mutex locks in $XDG_RUNTIME_DIR/.dotnet and
  # refuses any parent folder not owned by root or the user. Inside bwrap's
  # user namespace root isn't mapped, so the host's /run shows up as owned by
  # nobody. Mount the runtime dir at a top-level path instead, whose parent is
  # bwrap's own root and is owned by the user.
  extraPreBwrapCmds = ''
    xdg_runtime_args=()
    if [[ -d "''${XDG_RUNTIME_DIR:-}" ]]; then
      xdg_runtime_args=(
        --bind "$XDG_RUNTIME_DIR" /xdg-runtime
        --setenv XDG_RUNTIME_DIR /xdg-runtime
      )
    fi
  '';
  extraBwrapArgs = [ ''"''${xdg_runtime_args[@]}"'' ];

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

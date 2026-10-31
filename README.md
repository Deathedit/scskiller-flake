# scskiller-flake

Nix flake for [SCSKiller](https://github.com/BlueHeisenberg/SCSKiller), packaged from the upstream AppImage.

Currently packages **v1.4.2** for `x86_64-linux`.

## Usage

### Run directly

```sh
nix run github:Deathedit/scskiller-flake
```

### NixOS

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    scskiller = {
      url = "github:Deathedit/scskiller-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, scskiller, ... }: {
    nixosConfigurations.<hostname> = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ ... }: {
          environment.systemPackages = [ scskiller.packages.x86_64-linux.default ];
        })
      ];
    };
  };
}
```

### Home Manager

```nix
home.packages = [ inputs.scskiller.packages.x86_64-linux.default ];
```

### Overlay

```nix
nixpkgs.overlays = [ inputs.scskiller.overlays.default ];
environment.systemPackages = [ pkgs.scskiller ];
```

## Outputs

| Output | Description |
| --- | --- |
| `packages.x86_64-linux.scskiller` | The wrapped AppImage (also `default`) |
| `apps.x86_64-linux.default` | Runs `scskiller` |
| `overlays.default` | Adds `scskiller` to nixpkgs |

The package installs a `scskiller` binary, a desktop entry, and an icon.

## Updating

1. Bump `version` in `package.nix`.
2. Get the new hash:
   ```sh
   nix store prefetch-file https://github.com/BlueHeisenberg/SCSKiller/releases/download/v<version>/SCSKiller-x86_64.AppImage
   ```
3. Replace `hash` in `package.nix` and run `nix build`.

## Notes

SCSKiller is a self-contained .NET/Avalonia app run inside the `appimageTools` FHS sandbox. Its bundled Vulkan layer and injection components are left as shipped and have not been tested under this wrapper.

This flake only repackages upstream binaries; SCSKiller itself is developed by [BlueHeisenberg](https://github.com/BlueHeisenberg/SCSKiller).

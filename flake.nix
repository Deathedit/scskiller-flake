{
  description = "SCSKiller packaged from the upstream AppImage";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system} = {
        scskiller = pkgs.callPackage ./package.nix { };
        default = self.packages.${system}.scskiller;
      };

      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.scskiller}/bin/scskiller";
      };

      overlays.default = final: prev: {
        scskiller = final.callPackage ./package.nix { };
      };
    };
}

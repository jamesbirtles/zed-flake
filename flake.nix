{
  description = "Cached latest-stable Zed editor builds";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zed-stable.url = "github:zed-industries/zed/v0.233.8";
  };

  outputs =
    {
      self,
      nixpkgs,
      zed-stable,
      ...
    }:
    let
      systems = [ "x86_64-linux" ];
      forSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forSystems (system: {
        stable = zed-stable.packages.${system}.default;
        default = zed-stable.packages.${system}.default;
      });
    };

  nixConfig = {
    extra-substituters = [ "https://cache.garnix.io" ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };
}

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

      # Upstream's build.nix hardcodes "nightly" as the release channel,
      # version suffix, app name, desktop entry name, and icon filename,
      # regardless of which tag we pin. Rewrite those tokens so that
      # building from a stable tag produces a coherent stable artifact.
      mkStable =
        system:
        let
          lib = nixpkgs.lib;
          rebrand = lib.replaceStrings [
            "-nightly"
            "echo nightly"
            "app-icon-nightly"
            "Zed Nightly"
            "Zed-Nightly"
          ] [
            ""
            "echo stable"
            "app-icon"
            "Zed"
            "Zed"
          ];
        in
        (zed-stable.packages.${system}.default).overrideAttrs (old: {
          version = rebrand old.version;
          env = old.env // {
            RELEASE_VERSION = rebrand old.env.RELEASE_VERSION;
          };
          preBuild = rebrand old.preBuild;
          installPhase = rebrand old.installPhase;
        });
    in
    {
      packages = forSystems (
        system:
        let
          stable = mkStable system;
        in
        {
          inherit stable;
          default = stable;
        }
      );
    };

  nixConfig = {
    extra-substituters = [ "https://cache.garnix.io" ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };
}

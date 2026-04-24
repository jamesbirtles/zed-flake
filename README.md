# zed-flake

A thin wrapper around [Zed's upstream flake](https://github.com/zed-industries/zed) pinned to the latest **stable** release tag, built and cached by [Garnix](https://garnix.io/) so you don't have to recompile the editor locally.

A GitHub Actions workflow checks hourly for new stable Zed releases. When one appears, it bumps the pin and pushes; Garnix picks up the commit and publishes the build to `cache.garnix.io`. Once Garnix goes green, a second workflow tags the commit with the Zed version (e.g. `v0.233.8`) and moves the `stable` tag to it, so you can pin to a known-cached revision.

## Using it

Add it as an input to your own flake. Pin to the `stable` tag to always get the latest cached build, or to a specific `v*` tag for a fixed version:

```nix
{
  # Latest cached stable build (tag moves as new Zed releases pass Garnix):
  inputs.zed-flake.url = "github:jamesbirtles/zed-flake/stable";

  # Or pin to a specific Zed version:
  # inputs.zed-flake.url = "github:jamesbirtles/zed-flake/v0.233.8";

  outputs = { self, nixpkgs, zed-flake, ... }: {
    # e.g. in a NixOS module
    environment.systemPackages = [
      zed-flake.packages.x86_64-linux.default
    ];
  };
}
```

Or run it ad-hoc:

```sh
nix run github:jamesbirtles/zed-flake
```

### Trusting the cache

The flake declares `cache.garnix.io` as a substituter via `nixConfig`. For it to actually be used without a prompt, add it to your system-wide Nix config (or accept it per-invocation with `--accept-flake-config`):

```nix
# configuration.nix / nix.conf
nix.settings = {
  substituters = [ "https://cache.garnix.io" ];
  trusted-public-keys = [
    "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
  ];
};
```

## Outputs

| Output | Description |
|---|---|
| `packages.x86_64-linux.default` | Latest stable Zed (release profile) |
| `packages.x86_64-linux.stable`  | Alias of `default` |

Only `x86_64-linux` is built today. Other systems are a one-line addition to `flake.nix` once needed.

## Status

The pinned tag is whatever appears in `inputs.zed-stable.url` in `flake.nix`. Check the commit log for bump history.

## Credit

All the actual work of making Zed build under Nix is done by the [Zed team](https://github.com/zed-industries/zed). This repo just keeps a stable-release pin warm in a public cache.

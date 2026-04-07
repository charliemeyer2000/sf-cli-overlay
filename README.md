# sf-cli-overlay

Nix flake for [SF Compute CLI](https://sfcompute.com). Pre-built binaries, auto-updated every 6 hours.

## Usage

### Flake input

```nix
{
  inputs.sf-cli-overlay = {
    url = "github:charliemeyer2000/sf-cli-overlay";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

Add the overlay:

```nix
nixpkgs.overlays = [sf-cli-overlay.overlays.default];

# Then use pkgs.sf-cli in your packages
```

Or reference directly:

```nix
sf-cli-overlay.packages.${system}.sf
```

### Try without installing

```bash
nix run github:charliemeyer2000/sf-cli-overlay
```

### Pin a version

```nix
sf-cli-overlay.packages.${system}."0.31.5"
```

## How it works

`versions/*.json` files contain URLs and SHA256 hashes pointing to GitHub releases for [sfcompute/cli](https://github.com/sfcompute/cli). No binaries stored in git. `nix build` fetches and verifies at build time. GitHub Actions checks for new releases every 6 hours.

## Platforms

aarch64-darwin, x86_64-darwin, aarch64-linux, x86_64-linux

## License

Nix packaging: MIT. SF Compute CLI binary: proprietary (San Francisco Compute).

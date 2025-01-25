# MacOS Nix Config

My development environment, as codified into a nix home-manager config.

## Installation

1. Install [nix](https://nixos.org/download/) using the official instructions.
2. Make nix use the latest stable channel with:

```sh
nix-channel --add https://nixos.org/channels/nixos-24.11 nixpkgs
nix-channel --update
```

3. Follow the official instructions to install [home manager.](https://nix-community.github.io/home-manager/index.xhtml#sec-install-standalone)

4. Run:

```
home-manager switch
```

Whenever you need to update your configuration.

## Motivation

I work with researchers who are not software engineers quite a lot in my
day-to-day job, and they have trouble creating reliable software environments.
Accordingly, they are extremely interested in using [nix](https://nixos.org)
to manage their development.

As such, I have decided to make my personal configuration 100% reproducible
via home manager, with the hope that other people can read this code and
use it to begin their journey into learning and mastering nix.

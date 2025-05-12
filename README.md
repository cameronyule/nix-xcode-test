# Nix Xcode Test

A simple experiment to understand building Xcode projects with Nix.

## Rationale

The Nix standard build environment (`stdenv`) on Darwin differs from Linux in some important ways, including defaulting to Clang instead of GCC and providing various frameworks and libraries which together comprise the Apple SDK. Nix [makes this all available](https://nixos.org/manual/nixpkgs/stable/#sec-darwin) on Darwin by default, however build tooling is more complex. Apple's [`xcrun`](https://developer.apple.com/library/archive/technotes/tn2339/_index.html) and [`xcodebuild`](https://developer.apple.com/library/archive/technotes/tn2339/_index.html) tools are not open source and so cannot be distributed by Nix nor made available to install from Nixpkgs. In an attempt to provide some form of usable experience on Darwin, Nix ships [`xcbuild`](https://github.com/facebookarchive/xcbuild) which was an attempt to by Meta to build an Xcode-compatible build tool. Unfortunately, `xcbuild` hasn't been updated since 2019 and is not guaranteed to be compatible with newer Xcode projects.

To overcome this limitation, this test project uses [xcodeenv](https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/mobile/xcodeenv/compose-xcodewrapper.nix) to [expose the host system Xcode installation](https://nixos.org/manual/nixpkgs/stable/#ios) to Nix. By definition this means that a build produced in this manner will not be reproducible across systems, as the installation of Xcode is managed outside of the Nix dependency closure. There does not appear to be any way around this limitation currently.

## Installing Xcode
Xcode should be installed as normal per [Apple's documentation](https://developer.apple.com/xcode/).

## Development

We can start a Nix [development shell](https://nix.dev/manual/nix/2.28/command-ref/new-cli/nix3-develop) — which provides the full development environment we've specified with Nix — while also retaining our current shell configuration. This ensures we retain our prompt, aliases, access to programs installed on the host, etc.

``` shell
nix develop --command $SHELL
```

## Testing

While the above command is convenient for development, for testing we may want to try our build in an isolated environment closer to those used by [nix build](https://nix.dev/manual/nix/2.28/command-ref/new-cli/nix3-build). We can achieve this with the `--ignore-environment` option, which unsets all environment variables from the host shell (e.g., $PATH). We can use this in combation with the [`--norc`](https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html) option of Bash to also skip executing any startup commands specified on the host system (e.g., initialising Nix, invoking a custom prompt, etc).

``` shell
nix develop --ignore-environment --command bash --norc
```

## Build Xcode Project

Once in a development shell, [`xcodebuild`](https://developer.apple.com/library/archive/technotes/tn2339/_index.html) will be available along with any other dependencies declared in our flake.

``` shell
xcodebuild -project cli/cli.xcodeproj
```

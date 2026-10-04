# Skeleton

Skeleton theme template for ARGVUS: the starting point for every new official
theme package (`argvus-theme-<slug>`). It contains the same files and layout as
an official theme package, with neutral placeholder colors and no
theme-specific identity.

[![CI](https://github.com/argvus/skeleton-theme/actions/workflows/ci.yml/badge.svg)](https://github.com/argvus/skeleton-theme/actions/workflows/ci.yml)
[![Release](https://github.com/argvus/skeleton-theme/actions/workflows/release.yml/badge.svg)](https://github.com/argvus/skeleton-theme/actions/workflows/release.yml)
[![License](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](LICENSE)

## Create a new theme

Do not edit this repository in place for a real theme. Copy it, then run the
generator once in the copy:

```sh
cp -a <template> <new-dir>
cd <new-dir>
tools/sh/new_theme.sh nord-light "Nord Light"
```

The generator takes a slug (`^[a-z0-9]+(-[a-z0-9]+)*$`) and a display name. It
replaces the template identifiers in the packaging files, documentation and
`src/`, renames the theme files, and resets `pkgver` to `0.1.0` and the
changelog. It refuses to run once no template identifier is left.

After generating the theme, fill every `TODO(palette)` placeholder with the
official palette, then build and validate it. See
[DEVELOPMENT.md](DEVELOPMENT.md) for the full workflow.

## Build and install

On Arch Linux or a compatible distribution:

```sh
sudo pacman -S --needed base-devel git shellcheck
make validate
make build
make install
```

`make build` creates a deterministic local source archive in
`build/artifacts/` and a package in `build/dist/`. `make install` requires
`sudo` and installs the one package found in that directory without a blanket
`--overwrite` rule.

For package metadata only:

```sh
make validate
makepkg -p packaging/arch/ci/PKGBUILD --printsrcinfo
```

See [packaging/arch/README.md](packaging/arch/README.md) for the difference
between local and release builds.

## Documentation

- [DEVELOPMENT.md](DEVELOPMENT.md) — layout, checks, theme generation and releases
- [CONTRIBUTING.md](CONTRIBUTING.md) — contribution workflow
- [SECURITY.md](SECURITY.md) — private vulnerability reports

## License

SPDX: `GPL-3.0-only`. See [LICENSE](LICENSE).

# ARGVUS Git theme skeleton

Use this template to create a theme published in a Git repository and installed
with `argvus theme install`. It includes the schema-2 manifest, terminal override
and placeholder wallpaper used by the ARGVUS theme renderer.

## Create your theme

```sh
git clone https://github.com/argvus/argvus-skeleton-theme.git argvus-theme-ocean-night
cd argvus-theme-ocean-night
mv src/usr/share/argvus/themes/skeleton src/usr/share/argvus/themes/ocean-night
```

Edit `src/usr/share/argvus/themes/ocean-night/theme.toml`: set `id` to
`ocean-night`, `name` and `name_i18n` to your display name, and `category` to
`dark` or `light`. IDs contain lowercase letters, digits and single hyphens,
match their directory name, and must not end in `-spaced` or `-float`.

Choose `[palette].bg`, `fg` and `accent`; other colours have derived defaults.
Expressions such as `"@accent | alpha(0.3)"` follow the selected accent.
Adjust the `[ansi]` terminal colours as needed. Sticky and Spaced layouts share
the same theme palette. Readability depends on matching the palette to the
chosen dark/light category.

Replace the placeholder image under `src/usr/share/backgrounds/argvus/` with
an image you are allowed to redistribute. Update `wallpaper` in the manifest
to the matching `/usr/share/backgrounds/argvus/...` path. The Git installer
resolves that path inside the repository's `src/`, copies the image into the
user theme and rewrites the installed reference. Do not change a generated file.
Relative images inside the theme directory are supported too.

## Validate and publish

On an ARGVUS desktop, validate the manifest and render the installed consumers
in both layouts:

```sh
argvus theme check src/usr/share/argvus/themes/ocean-night
```

The repository must contain exactly one theme under
`src/usr/share/argvus/themes/<id>/`. Its overrides and images must be regular
files committed to Git. Submodules and Git LFS are unsupported. Include a
LICENSE covering your assets and update the author information as appropriate.

Publish the repository to your own Git host (for example
`https://github.com/USER/argvus-theme-ocean-night.git`), then install and apply:

```sh
argvus theme install https://github.com/USER/argvus-theme-ocean-night.git
argvus theme apply ocean-night
```

Installation uses the remote default branch. `--ref v1.0` selects a branch or
tag, and `--replace` explicitly replaces an existing custom theme after you
publish changes. Reapply the theme to see the updated appearance.

The theme appears in **Control Center → Appearance → Themes → Custom themes**;
press `r` to refresh an already open page. Installation is per user under
`$XDG_DATA_HOME/argvus/themes/<id>/` and does not activate the theme.
Apply another theme before removing it with `argvus theme uninstall ocean-night`.
Installed official IDs cannot be replaced.

## Arch Linux packages

Git installation requires only the theme files in `src/`. This skeleton does
not include `packaging/`, `tools/` or a Makefile. To create `.pkg.tar.zst`
packages, use [argvus-skeleton-theme-zst](https://github.com/argvus/argvus-skeleton-theme-zst),
which keeps the Arch packaging workflow and the same theme format in `src/`.

See [DEVELOPMENT.md](DEVELOPMENT.md) for the source layout and contribution notes.

## License

GPL-3.0-only. See [LICENSE](LICENSE).

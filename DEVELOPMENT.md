# Theme development

This is the Git theme template. Authoritative files live in `src/`:

- `usr/share/argvus/themes/<id>/theme.toml`: identity, palette, assets and overrides.
- `usr/share/argvus/themes/<id>/overrides/`: optional consumer templates.
- `usr/share/backgrounds/argvus/`: bundled wallpaper images.

Follow [README.md](README.md) to rename the template directory and edit the
identity manually. Keep the theme ID equal to its directory name. The same
schema-2 manifest serves the Sticky and Spaced layouts.

Run `argvus theme check src/usr/share/argvus/themes/<id>` on an ARGVUS desktop.
This renders against the installed component templates. Verify that each asset
exists in `src/` as well; template rendering alone does not establish that an
image is available. Publish the edited source before installing it via its Git
URL. After a change, publish again and use `argvus theme install URL --replace`,
then `argvus theme apply <id>` to inspect the appearance. Test both layouts and
custom accent colours on the desktop.

Rendered files in the ARGVUS generated directory are derived state. Change the
source manifest, overrides or assets instead. No package build, Makefile or
repository scripts are required for the Git workflow.

For Arch Linux package development, use
[argvus-skeleton-theme-zst](https://github.com/argvus/argvus-skeleton-theme-zst).

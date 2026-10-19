#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

die() {
	printf 'error: %s\n' "$1" >&2
	exit 1
}

require_command() {
	command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

require_command bash
require_command makepkg
require_command shellcheck

cd "$ROOT_DIR"

shellcheck tools/sh/*.sh packaging/arch/common/*.sh
bash -n tools/sh/*.sh packaging/arch/common/*.sh

# Payload scripts are optional: theme packages may ship none.
payload_scripts=()
while IFS= read -r -d '' script; do
	payload_scripts+=("$script")
done < <(find src -type f -name '*.sh' -print0 | sort -z)

if (( ${#payload_scripts[@]} > 0 )); then
	shellcheck "${payload_scripts[@]}"
	bash -n "${payload_scripts[@]}"
fi

metadata() {
	bash -c '
		source "$1"
		printf "%s\n" "$pkgname" "$pkgver" "$pkgrel" "$pkgdesc"
		printf "%s\n" "${arch[*]}" "${license[*]}" "${depends[*]}"
		printf "%s\n" "${makedepends[*]}" "${options[*]}"
	' bash "$1"
}

ci_metadata="$(metadata packaging/arch/ci/PKGBUILD)"
local_metadata="$(metadata packaging/arch/local/PKGBUILD)"
[[ "$ci_metadata" == "$local_metadata" ]] || die \
	"CI and local PKGBUILD metadata is out of sync"

# argvus is the master package: every component, theme included, depends on it.
# Line 7 of the metadata is the depends array.
depends_line="$(printf '%s\n' "$ci_metadata" | sed -n 7p)"
case " $depends_line " in
	*" argvus "*) ;;
	*) die "packaging/arch/ci/PKGBUILD must depend on argvus (the master package)" ;;
esac

# Removed components must not ship configuration. snappy-switcher was removed.
if find src -iname '*snappy*' -print -quit | grep -q .; then
	die "src/ ships snappy-switcher files, a removed component"
fi

for pkgbuild_dir in packaging/arch/ci packaging/arch/local; do
	pkgbuild="$pkgbuild_dir/PKGBUILD"
	[[ -f "$pkgbuild" ]] || die "missing $pkgbuild"
	(
		cd "$pkgbuild_dir"
		makepkg -p PKGBUILD --printsrcinfo >/dev/null
	)
done

# A theme manifest names resources that the package must ship. Missing ones are
# silently skipped at runtime (no wallpaper, no calendar stylesheet), so catch
# them here instead.
for manifest in src/usr/share/argvus/appearance/themes.d/*/theme.toml; do
	[[ -f "$manifest" ]] || die "no theme manifest under src/usr/share/argvus/appearance/themes.d/"
	theme_dir="$(basename -- "$(dirname -- "$manifest")")"
	manifest_id="$(sed -n 's/^id = "\(.*\)"$/\1/p' "$manifest" | head -n 1)"
	[[ "$manifest_id" == "$theme_dir" ]] || die "$manifest: id '$manifest_id' does not match its directory"

	wallpaper="$(sed -n 's/^wallpaper = "\([^"]*\)".*/\1/p' "$manifest" | head -n 1)"
	# The template ships no wallpaper; new_theme.sh renames the theme and the
	# wallpaper must then exist, so only the generated theme is checked here.
	if [[ "$manifest_id" == skeleton ]]; then
		printf 'note: %s is the template; the wallpaper is checked after new_theme.sh\n' "$manifest"
	elif [[ -n "$wallpaper" ]]; then
		[[ -f "src/usr/share/backgrounds/argvus/$wallpaper" ]] || die \
			"$manifest: wallpaper '$wallpaper' is not in src/usr/share/backgrounds/argvus/ (ship it or fix the path)"
	fi

	calendar_css="$(sed -n 's/^calendar_css = "\([^"]*\)".*/\1/p' "$manifest" | head -n 1)"
	if [[ -n "$calendar_css" ]]; then
		[[ -f "src/etc/argvus/taskbar/calendar/themes/$calendar_css.css" ]] || die \
			"$manifest: calendar stylesheet '$calendar_css.css' is not under src/etc/argvus/taskbar/calendar/themes/"
	fi
done

git diff --check
printf 'Validation OK\n'

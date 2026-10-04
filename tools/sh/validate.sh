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

for pkgbuild_dir in packaging/arch/ci packaging/arch/local; do
	pkgbuild="$pkgbuild_dir/PKGBUILD"
	[[ -f "$pkgbuild" ]] || die "missing $pkgbuild"
	(
		cd "$pkgbuild_dir"
		makepkg -p PKGBUILD --printsrcinfo >/dev/null
	)
done

git diff --check
printf 'Validation OK\n'

.PHONY: help build package install install-package clean validate lint spellcheck changelog

.DEFAULT_GOAL := help

# Shell scripts shipped in the payload (src/). Empty for theme packages that
# install no scripts, in which case the payload checks are skipped.
payload_scripts := $(shell find src -type f -name '*.sh' 2>/dev/null | sort)

help:
	@echo "Available targets:"
	@echo "  make build           - build the package into build/"
	@echo "  make package         - alias for make build"
	@echo "  make install         - install the single local package (sudo pacman -U)"
	@echo "  make clean           - remove build/ outputs"
	@echo "  make validate        - run required repository and PKGBUILD checks"
	@echo "  make lint            - run local static checks"
	@echo "  make spellcheck      - run cspell (if installed)"
	@echo "  make changelog       - regenerate CHANGELOG.md with git-cliff"

build:
	@tools/sh/pkgbuild_local.sh

package: build

install:
	@set -e; \
	package="$$(find build/dist -maxdepth 1 -type f -name '*.pkg.tar.zst' -print | sort | head -n 1)"; \
	count="$$(find build/dist -maxdepth 1 -type f -name '*.pkg.tar.zst' -print | wc -l)"; \
	if [ "$$count" -ne 1 ] || [ -z "$$package" ]; then \
		echo "Expected exactly one package in build/dist; run 'make clean && make build'." >&2; \
		exit 1; \
	fi; \
	sudo pacman -U "$$package"

install-package: install

validate:
	@tools/sh/validate.sh

lint:
	@shellcheck tools/sh/*.sh packaging/arch/common/*.sh
	@bash -n tools/sh/*.sh packaging/arch/common/*.sh
	@if [ -n "$(payload_scripts)" ]; then \
		shellcheck $(payload_scripts) && bash -n $(payload_scripts); \
	fi
	@git diff --check
	@echo "Lint OK"

spellcheck:
	@if command -v cspell >/dev/null 2>&1; then \
		cspell --config cspell.json .; \
	else \
		echo "cspell is not installed; skipping (CI runs it)." >&2; \
	fi

changelog:
	@git-cliff -o CHANGELOG.md

clean:
	rm -rf -- build/

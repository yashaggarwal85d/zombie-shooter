#!/usr/bin/env bash
# Downloads the pinned Godot editor (and optionally export templates) and
# checks them against known SHA-512 hashes. Used by CI; works locally on Linux.
# Usage: tools/ci/install_godot.sh <install_dir> [--templates]
set -euo pipefail

GODOT_VERSION="4.7.2"
GODOT_FLAVOR="stable"
EDITOR_SHA512="9aa00f7a605200940bce3027a567b782f49bd8e940dd06ae9e987bd65aee1b1467edd56ed84fcdcbdd44354bf613bdbb4e5d2913e925850368e150c59ed54c65"
TEMPLATES_SHA512="ca4d71c4d7b81dfc15d1a98baa07534aa95b03fdda78a0075b06672e1648d2e5f40980c9adc28d23e1b92e732ee7bf3461997aa804af74ec2fcd7a93ccb84079"
BASE="https://downloads.godotengine.org/?version=${GODOT_VERSION}&flavor=${GODOT_FLAVOR}"

dest="${1:?install dir required}"
mkdir -p "$dest"
cd "$dest"

binary="Godot_v${GODOT_VERSION}-${GODOT_FLAVOR}_linux.x86_64"
if [[ ! -x "$binary" ]]; then
  curl -fsSL --retry 4 -o godot.zip "${BASE}&slug=linux.x86_64.zip&platform=linux.64"
  echo "${EDITOR_SHA512}  godot.zip" | sha512sum -c -
  unzip -q -o godot.zip && rm godot.zip
fi
ln -sf "$PWD/$binary" "$PWD/godot"

if [[ "${2:-}" == "--templates" ]]; then
  tdir="$HOME/.local/share/godot/export_templates/${GODOT_VERSION}.${GODOT_FLAVOR}"
  if [[ ! -f "$tdir/version.txt" ]]; then
    curl -fsSL --retry 4 -o templates.tpz "${BASE}&slug=export_templates.tpz&platform=templates"
    echo "${TEMPLATES_SHA512}  templates.tpz" | sha512sum -c -
    mkdir -p "$tdir"
    # Only the platforms we build on Linux; iOS exports need macOS + Xcode.
    unzip -q -o -j templates.tpz 'templates/version.txt' 'templates/windows_*_x86_64*' 'templates/android_*.apk' -d "$tdir"
    rm templates.tpz
  fi
fi

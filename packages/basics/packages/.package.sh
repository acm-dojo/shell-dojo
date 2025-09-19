#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

BUNDLE_DIR="cowsay-bundle-root"

# Modules cowsay uses (names with ::)
MODULES=(
  "Text::Tabs"
  "Text::Wrap"
  "File::Basename"
  "Getopt::Std"
  "Cwd"
  "Text::CharWidth"
  "Encode"
)

rm -rf "$BUNDLE_DIR"
mkdir -p "$BUNDLE_DIR"

# helper: find module file path
find_module_path() {
  local mod="$1"
  # convert Text::Tabs -> Text/Tabs.pm
  local incpath="${mod//:://}.pm"

  # 1) try perldoc -l
  if command -v perldoc >/dev/null 2>&1; then
    local p
    p=$(perldoc -l "$mod" 2>/dev/null || true)
    if [[ -n "$p" && -f "$p" ]]; then
      printf '%s\n' "$p"
      return 0
    fi
  fi

  # 2) try to load the module and query %INC
  local p2
  p2=$(perl -e 'my ($m,$p)=@ARGV; eval "use $m"; print $INC{$p} if $INC{$p}' "$mod" "$incpath" 2>/dev/null || true)
  if [[ -n "$p2" && -f "$p2" ]]; then
    printf '%s\n' "$p2"
    return 0
  fi

  # 3) fallback: scan @INC dirs for the file path
  local incs
  incs=$(perl -e 'print join(" ", @INC)')
  for d in $incs; do
    # try the direct file
    if [[ -f "$d/$incpath" ]]; then
      printf '%s\n' "$d/$incpath"
      return 0
    fi
    # also try common alternate locations (site_perl etc)
    if [[ -f "$d/lib/$incpath" ]]; then
      printf '%s\n' "$d/lib/$incpath"
      return 0
    fi
  done

  # not found
  return 1
}

echo "[*] Locating and copying required Perl modules..."
for mod in "${MODULES[@]}"; do
  printf " - %s: " "$mod"
  if path=$(find_module_path "$mod"); then
    echo "$path"
    # copy the file and keep parent dirs
    cp --parents -a "$path" "$BUNDLE_DIR/"
  else
    echo "NOT FOUND"
    echo "    -> Module $mod not found on this system. You may need to install the package that provides it (e.g. libtext-charwidth-perl or perl-modules-<ver>)."
    exit 1
  fi

  # If the module has an associated XS/shared object install that too.
  # Example: Cwd -> auto/Cwd/Cwd.so, Text::CharWidth -> auto/Text/CharWidth/CharWidth.so
  base="${mod//:://}"
  so1="$(dirname "$path")/auto/${base##*/}/${base##*/}.so"
  so2="$(dirname "$path")/auto/${base%/*}/${base##*/}.so" # try a couple variants
  for so in "$so1" "$so2"; do
    if [[ -f "$so" ]]; then
      echo "    + copying XS object $so"
      cp --parents -a "$so" "$BUNDLE_DIR/"
    fi
  done
done

echo "[*] Copying cowsay executable(s) and cowfiles..."
# cowsay binary and cow files
if [[ -x "/usr/games/cowsay" ]]; then
  cp --parents -a /usr/games/cowsay "$BUNDLE_DIR/"
fi
if [[ -x "/usr/games/cowthink" ]]; then
  cp --parents -a /usr/games/cowthink "$BUNDLE_DIR/"
fi
if [[ -d "/usr/share/cowsay" ]]; then
  cp -a --parents /usr/share/cowsay "$BUNDLE_DIR/"
fi

# Also copy any man pages (optional)
if [[ -d "/usr/share/man/man6" ]]; then
  find /usr/share/man/man6 -type f -name "cowsay*" -exec cp --parents -a {} "$BUNDLE_DIR/" \; 2>/dev/null || true
fi

echo "[*] Done. Bundle root created at: $BUNDLE_DIR"
echo "Next: build a .deb with fpm (example):"
echo "  fpm -s dir -t deb -n cowsay-bundle -v 3.03 --prefix=/ -C $BUNDLE_DIR usr etc"

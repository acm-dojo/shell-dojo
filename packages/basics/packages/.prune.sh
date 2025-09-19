#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

BUNDLE="cowsay-bundle-root"
TIMESTAMP=$(date +%s)
BACKUP="/tmp/${BUNDLE}-backup-${TIMESTAMP}.tar.gz"
REPORT="/tmp/cowsay-prune-report-${TIMESTAMP}.txt"
ALLOWED_PKGS=(cowsay libtext-charwidth-perl)   # packages whose files we intentionally keep

# -------------- safety checks --------------
if [[ ! -d "$BUNDLE" ]]; then
  echo "ERROR: bundle directory '$BUNDLE' not found in $(pwd)"
  exit 1
fi

echo "Backing up '$BUNDLE' -> $BACKUP (so you can recover if needed)..."
tar -czf "$BACKUP" "$BUNDLE"

echo "Scanning bundle for files that are owned by installed packages..."
> "$REPORT"
printf "prune report generated: %s\n\n" "$REPORT" | tee -a "$REPORT"
printf "Bundle: %s\nBackup: %s\nAllowed packages: %s\n\n" "$BUNDLE" "$BACKUP" "${ALLOWED_PKGS[*]}" | tee -a "$REPORT"

# -------------- find and remove offending files --------------
# We'll record: owner, file, action
echo "Files that will be REMOVED (owned by other packages) are listed below." | tee -a "$REPORT"
echo "----" >> "$REPORT"

# Iterate bundle files
find "$BUNDLE" -type f -print0 |
  while IFS= read -r -d '' f; do
    # compute absolute path as it would be on target system
    abs="/${f#./$BUNDLE/}"   # converts e.g. cowsay-bundle-root/usr/games/cowsay -> /usr/games/cowsay
    # check ownership
    owner_info=$(dpkg -S "$abs" 2>/dev/null || true)
    if [[ -n "$owner_info" ]]; then
      pkg="${owner_info%%:*}"
      # if owner pkg NOT in allowed list, remove file
      keep=0
      for a in "${ALLOWED_PKGS[@]}"; do
        if [[ "$pkg" == "$a" ]]; then keep=1; break; fi
      done

      if [[ $keep -eq 0 ]]; then
        printf "REMOVE: %s  (owned by: %s)\n" "$abs" "$pkg" | tee -a "$REPORT"
        rm -f -- "$f"
      else
        printf "KEEP:   %s  (owned by allowed pkg: %s)\n" "$abs" "$pkg" >> "$REPORT"
      fi
    else
      # free file (not owned by any installed package) — keep it
      printf "FREE:   %s\n" "$abs" >> "$REPORT"
    fi
  done

# -------------- cleanup empty dirs --------------
echo "Cleaning up empty directories in the bundle..."
# remove directories that became empty
find "$BUNDLE" -type d -empty -delete

# -------------- report remaining owned files (if any) --------------
echo -e "\nChecking for any remaining files in the bundle that are still owned by installed packages..."
remaining=0
find "$BUNDLE" -type f -print0 |
  while IFS= read -r -d '' f; do
    abs="/${f#./$BUNDLE/}"
    owner_info=$(dpkg -S "$abs" 2>/dev/null || true)
    if [[ -n "$owner_info" ]]; then
      printf "CONFLICT: %s -> %s\n" "$abs" "$owner_info" | tee -a "$REPORT"
      remaining=1
    fi
  done

if [[ $remaining -eq 1 ]]; then
  echo -e "\nWARNING: Some files in the bundle are still owned by installed packages. See $REPORT"
  echo "You should inspect those files and decide whether to remove them or add them to ALLOWED_PKGS."
else
  echo -e "\nNo remaining owned-file conflicts detected. Bundle is clean relative to installed packages."
fi

# -------------- optional: build .deb with fpm --------------
# Build only if fpm is installed. If you don't want to build, skip this step.
if command -v fpm >/dev/null 2>&1; then
  OUTNAME="cowsay-bundle_3.03_$(dpkg --print-architecture).deb"
  echo -e "\nBuilding .deb with fpm..."
  # Ensure we only include top-level usr and etc if they exist
  PKG_CONTENTS=()
  [[ -d "$BUNDLE/usr" ]] && PKG_CONTENTS+=(usr)
  [[ -d "$BUNDLE/etc" ]] && PKG_CONTENTS+=(etc)
  if [[ ${#PKG_CONTENTS[@]} -eq 0 ]]; then
    echo "No usr/ or etc/ in bundle to package. Skipping build."
  else
    fpm -s dir -t deb -n cowsay-bundle -v 3.03 --prefix=/ -C "$BUNDLE" "${PKG_CONTENTS[@]}"
    echo "Built: ./cowsay-bundle_3.03_$(dpkg --print-architecture).deb"
  fi
else
  echo -e "\n'fpm' not found; skipping .deb build. Install fpm (gem install fpm) to auto-build."
fi

echo -e "\nDone. Full report at: $REPORT"
echo "If anything was removed by mistake you can restore the backup:"
echo "  tar -xzf $BACKUP -C /  (extracts the bundle back to current dir)"

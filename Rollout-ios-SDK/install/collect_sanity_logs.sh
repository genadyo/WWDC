#!/bin/bash
BIN_DIR="$(cd "$(dirname "$0")" && pwd )"
BASE_DIR="$(dirname "$BIN_DIR")"
CACHE_DIR="$BASE_DIR/.cache"

"$BIN_DIR/print_targets.rb" "$1"
for f in "$CACHE_DIR"/sanity* ; do
  echo "---- $f ----"
  cat "$f" || echo "$f" not found
done

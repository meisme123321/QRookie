#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$ROOT_DIR/build"

check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: '$1' is not installed." >&2
        return 1
    fi
}

check_command cmake
check_command git

if [ ! -d "$ROOT_DIR/.git" ] && ! git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Warning: project root is not a git repository." >&2
fi

pushd "$ROOT_DIR" >/dev/null

REVISION=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

cat <<EOF
Building QRookie from:
  root:      $ROOT_DIR
  branch:    $BRANCH
  revision:  $REVISION
  build dir: $BUILD_DIR
EOF

cmake -S "$ROOT_DIR" -B "$BUILD_DIR"
cmake --build "$BUILD_DIR" --parallel "$(nproc)"

cat <<EOF
Build completed successfully.
Executable created at:
  $BUILD_DIR/qrookie
EOF

popd >/dev/null

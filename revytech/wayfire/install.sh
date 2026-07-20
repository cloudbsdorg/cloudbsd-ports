#!/bin/sh
# install.sh — build & install REVYTECH Wayfire stack via ports + pkg
# Every run: make stage → make reinstall (pkg-registered packages).
set -eu
ROOT="$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)"
exec "$ROOT/revytech/wayfire/scripts/build-and-pkg-install.sh" "$@"

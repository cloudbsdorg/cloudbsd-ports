#!/bin/sh
# install.sh — build & install the REVYTECH Wayfire stack from this ports tree.
#
# Prerequisites (FreeBSD / CloudBSD):
#   - git, pkg, a working compiler (clang from base or ports)
#   - doas or sudo for package install
#   - network access to github.com (distfiles + submodules)
#
# Usage:
#   ./revytech/wayfire/install.sh              # full desktop meta
#   ./revytech/wayfire/install.sh --makesum    # only refresh distinfo
#   ./revytech/wayfire/install.sh --ports-only # stop after build, no install
#   PORTSDIR=/path/to/cloudbsd-ports ./revytech/wayfire/install.sh
#
# Safe to re-run. Uses BATCH=yes. Does not force-remove stock wayfire; if you
# already have stock packages, uninstall them first:
#   pkg delete -y wayfire wf-shell wf-config wcm wayfire-plugins-extra

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)"
export PORTSDIR="${PORTSDIR:-$ROOT}"
export BATCH="${BATCH:-yes}"
export FORCE_PACKAGE_REGISTER="${FORCE_PACKAGE_REGISTER:-1}"

DOAS=
if command -v doas >/dev/null 2>&1; then
	DOAS=doas
elif command -v sudo >/dev/null 2>&1; then
	DOAS=sudo
else
	echo "error: need doas or sudo to install packages" >&2
	exit 1
fi

MAKE_CMD="${MAKE:-make}"
MAKESUM_ONLY=0
PORTS_ONLY=0

for arg in "$@"; do
	case "$arg" in
	--makesum) MAKESUM_ONLY=1 ;;
	--ports-only) PORTS_ONLY=1 ;;
	-h|--help)
		sed -n '2,20p' "$0"
		exit 0
		;;
	*)
		echo "unknown arg: $arg" >&2
		exit 1
		;;
	esac
done

log() { printf '%s %s\n' "$(date '+%Y-%m-%dT%H:%M:%S')" "$*"; }

# Build order (dependencies first)
PORTS="
devel/revytech-wf-config
x11-wm/revytech-wayfire
x11-wm/revytech-wayfire-plugins-extra
x11/revytech-wf-shell
x11/revytech-wcm
x11/revytech-wf-osk
x11-wm/revytech-wayfire-desktop
"

# Runtime build deps commonly missing on a fresh FreeBSD box
RUNTIME_BUILD_PKGS="
pkgconf meson ninja cmake git
evdev-proto wayland-protocols glm libevdev libinotify libinput
libdrm libudev-devd libxkbcommon yyjson cairo pango
gtk4 gtkmm40 gtk4-layer-shell libdbusmenu pulseaudio
boost-libs seatd
"

log "PORTSDIR=$PORTSDIR"
log "installing common build dependencies via pkg (best-effort)"
$DOAS pkg install -y $RUNTIME_BUILD_PKGS 2>/dev/null || \
	log "warning: some pkg deps failed; ports may still resolve them"

makesum_one() {
	port="$1"
	dir="$PORTSDIR/$port"
	[ -d "$dir" ] || { log "missing $dir"; return 1; }
	log "makesum $port"
	( cd "$dir" && $MAKE_CMD makesum DISTDIR="${DISTDIR:-/usr/ports/distfiles}" ) || \
	( cd "$dir" && $MAKE_CMD makesum )
}

build_one() {
	port="$1"
	dir="$PORTSDIR/$port"
	[ -d "$dir" ] || { log "missing $dir"; return 1; }
	log "building $port"
	cd "$dir"
	# Ensure distinfo exists
	if [ ! -f distinfo ] || [ ! -s distinfo ]; then
		$MAKE_CMD makesum || true
	fi
	$MAKE_CMD clean
	$MAKE_CMD package
	if [ "$PORTS_ONLY" -eq 0 ]; then
		log "installing $port"
		$DOAS $MAKE_CMD reinstall || $DOAS $MAKE_CMD install
	fi
}

if [ "$MAKESUM_ONLY" -eq 1 ]; then
	for p in $PORTS; do
		# skip meta
		case "$p" in
		*-desktop) continue ;;
		esac
		makesum_one "$p"
	done
	log "distinfo refreshed"
	exit 0
fi

for p in $PORTS; do
	build_one "$p"
done

log "REVYTECH Wayfire stack done."
log "Next: configure seatd, write ~/.config/wayfire.ini, start a session."
log "Pins: see $PORTSDIR/revytech/wayfire/VERSIONS"

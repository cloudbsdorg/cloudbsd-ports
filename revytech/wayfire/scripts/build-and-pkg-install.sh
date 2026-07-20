#!/bin/sh
set -eu
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
export PORTSDIR="${PORTSDIR:-/home/mlapointe/git/cloudbsd-ports}"
export DISTDIR="${DISTDIR:-$HOME/.cache/revytech-distfiles}"
export BATCH=yes
export PACKAGES="${PACKAGES:-$HOME/.cache/revytech-packages}"
mkdir -p "$DISTDIR" "$PACKAGES"
DOAS=doas
LOG=/tmp/revytech-build-all.log
log() { printf '%s %s\n' "$(date '+%H:%M:%S')" "$*" | tee -a "$LOG"; }

build_one() {
  port=$1
  name=$(basename "$port")
  log "=== START $port ==="
  cd "$PORTSDIR/$port"
  doas make clean >>"/tmp/revytech-$name.log" 2>&1 || true
  if ! make stage >>"/tmp/revytech-$name.log" 2>&1; then
    log "STAGE FAIL $port"
    tail -50 "/tmp/revytech-$name.log"
    return 1
  fi
  make makeplist 2>/dev/null | grep -v '^/you' > pkg-plist || true
  sed -i '' 's/\.so\.%%VERSION%%/.so.0.11.0/g' pkg-plist 2>/dev/null || true
  if ! $DOAS make reinstall >>"/tmp/revytech-$name.log" 2>&1; then
    log "REINSTALL FAIL $port"
    tail -50 "/tmp/revytech-$name.log"
    return 1
  fi
  make package >>"/tmp/revytech-$name.log" 2>&1 || true
  find work -name '*.pkg' -exec cp -f {} "$PACKAGES/" \; 2>/dev/null || true
  log "INSTALLED: $(pkg info -E "$name" 2>/dev/null || echo FAIL)"
}

: > "$LOG"
PORTS="${*:-devel/revytech-wf-config x11-wm/revytech-wayfire x11-wm/revytech-wayfire-plugins-extra x11/revytech-wf-shell x11/revytech-wcm x11/revytech-wf-osk}"
for p in $PORTS; do
  build_one "$p" || exit 1
done
log "=== ALL PACKAGES ==="
pkg info -x revytech || true
ls -la /usr/local/bin/wayfire /usr/local/bin/wf-panel /usr/local/bin/wf-settings /usr/local/bin/wf-background /usr/local/bin/wcm 2>&1 || true
wayfire --version 2>&1 || true
log DONE

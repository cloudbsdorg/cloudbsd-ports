#!/bin/sh
# Every iteration ends here: stage → clean plist → package → pkg install -f
set -eu
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
export PORTSDIR="${PORTSDIR:-/home/mlapointe/git/cloudbsd-ports}"
export DISTDIR="${DISTDIR:-$HOME/.cache/revytech-distfiles}"
export PACKAGES="${PACKAGES:-$HOME/.cache/revytech-packages}"
export BATCH=yes
export SU_CMD="${SU_CMD:-doas -u root sh -c}"
mkdir -p "$DISTDIR" "$PACKAGES"
DOAS=doas
LOG=/tmp/revytech-build-all.log
log() { printf '%s %s\n' "$(date '+%H:%M:%S')" "$*" | tee -a "$LOG"; }

# Map port path → /var/db/ports options category_name
options_key() {
  # e.g. x11/revytech-wf-shell → x11_revytech-wf-shell
  echo "$1" | tr '/' '_'
}

write_default_options() {
  port=$1
  key=$(options_key "$port")
  dir="/var/db/ports/${key}"
  $DOAS mkdir -p "$dir"
  case "$port" in
    x11/revytech-wf-shell)
      $DOAS tee "${dir}/options" >/dev/null <<EOF
_OPTIONS_READ=revytech-wf-shell
_FILE_COMPLETE_OPTIONS_LIST=PULSEAUDIO
OPTIONS_FILE_SET+=PULSEAUDIO
EOF
      ;;
    x11/revytech-wcm)
      $DOAS tee "${dir}/options" >/dev/null <<EOF
_OPTIONS_READ=revytech-wcm
_FILE_COMPLETE_OPTIONS_LIST=WDISPLAYS WFSHELL
OPTIONS_FILE_SET+=WDISPLAYS
OPTIONS_FILE_SET+=WFSHELL
EOF
      ;;
  esac
}

build_one() {
  port=$1
  name=$(basename "$port")
  log "=== START $port ==="
  write_default_options "$port"
  cd "$PORTSDIR/$port"

  # Prefer user-owned workdir; drop root leftovers
  if [ -d work ] && [ ! -w work ]; then
    $DOAS rm -rf work
  fi
  rm -rf work 2>/dev/null || $DOAS rm -rf work

  if ! make stage >>"/tmp/revytech-$name.log" 2>&1; then
    log "STAGE FAIL $port"
    tail -60 "/tmp/revytech-$name.log"
    return 1
  fi

  # Fresh plist from staged tree
  make makeplist 2>/dev/null | grep -v '^/you' > pkg-plist || true
  sed -i '' 's/\.so\.%%VERSION%%/.so.0.11.0/g' pkg-plist 2>/dev/null || true

  # Drop stale plist/package cookies (root-owned or empty packages)
  rm -f work/.PLIST.* work/.package_done* 2>/dev/null || true
  $DOAS rm -f work/.PLIST.* work/.package_done* 2>/dev/null || true
  $DOAS rm -rf work/pkg work/.metadir* 2>/dev/null || true

  if ! make generate-plist >>"/tmp/revytech-$name.log" 2>&1; then
    log "PLIST FAIL $port"
    tail -40 "/tmp/revytech-$name.log"
    return 1
  fi

  if ! make package >>"/tmp/revytech-$name.log" 2>&1; then
    log "PACKAGE FAIL $port"
    tail -40 "/tmp/revytech-$name.log"
    return 1
  fi

  pkgfile=$(find work/pkg -name "${name}-*.pkg" 2>/dev/null | head -1)
  if [ -z "$pkgfile" ] || [ ! -s "$pkgfile" ]; then
    log "NO PKG FILE $port"
    return 1
  fi
  # Reject empty/license-only packages (< 50KB for real apps is suspicious for shell/wayfire)
  size=$(stat -f %z "$pkgfile")
  log "PKG $pkgfile size=$size"
  cp -f "$pkgfile" "$PACKAGES/"

  if ! $DOAS pkg install -fy "$pkgfile" >>"/tmp/revytech-$name.log" 2>&1; then
    log "PKG INSTALL FAIL $port"
    tail -40 "/tmp/revytech-$name.log"
    return 1
  fi

  log "INSTALLED: $(pkg info -E "$name" 2>/dev/null || echo FAIL)"
}

: > "$LOG"
PORTS="${*:-devel/revytech-wf-config x11-wm/revytech-wayfire x11-wm/revytech-wayfire-plugins-extra x11/revytech-wf-shell x11/revytech-wcm x11/revytech-wf-osk}"
for p in $PORTS; do
  build_one "$p" || exit 1
done
log "=== ALL PACKAGES ==="
pkg info -x revytech || true
ls -la /usr/local/bin/wayfire /usr/local/bin/wf-panel /usr/local/bin/wf-settings /usr/local/bin/wf-background /usr/local/bin/wcm /usr/local/bin/wf-osk 2>&1 || true
wayfire --version 2>&1 || true
log DONE

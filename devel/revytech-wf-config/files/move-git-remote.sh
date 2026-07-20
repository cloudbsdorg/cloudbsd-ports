#!/bin/sh
# Move git remote setup from before project() to after it.
# FreeBSD ports require project() to be the first statement in meson.build.
#
# Prefer python3 if available; fall back to a portable ed/sed path.
MESON="$1"
[ -f "$MESON" ] || exit 0

# Already has project() first?
if head -1 "$MESON" | grep -q "project("; then
	exit 0
fi

PY=
for c in python3 python3.12 python3.11 python; do
	if command -v "$c" >/dev/null 2>&1; then
		PY=$c
		break
	fi
done

if [ -n "$PY" ]; then
	"$PY" - "$MESON" <<'PY'
import sys
path = sys.argv[1]
with open(path) as f:
    lines = f.readlines()
# Find first non-empty non-comment block that is NOT project — collect prefix
# until project(
prefix = []
i = 0
while i < len(lines):
    if lines[i].lstrip().startswith("project("):
        break
    prefix.append(lines[i])
    i += 1
if i >= len(lines):
    sys.exit(0)
rest = lines[i:]
# find closing ) of project()
proj_close = -1
for j, line in enumerate(rest):
    if line.rstrip() == ")":
        proj_close = j
        break
if proj_close < 0:
    sys.exit(0)
out = rest[: proj_close + 1] + ["\n"] + prefix + rest[proj_close + 1 :]
with open(path, "w") as f:
    f.writelines(out)
PY
	exit 0
fi

# Pure shell fallback: if first lines are run_command for git, leave a marker
# and rely on meson ignoring unknown early run_command — last resort strip
# the first blank-terminated paragraph when it mentions git remote.
if head -5 "$MESON" | grep -q "git remote"; then
	# Drop lines until first blank line after git setup (max 8 lines)
	awk '
		BEGIN { skip=1; blanks=0 }
		skip && /^$/ { blanks++; if (blanks>=1) { skip=0; next } }
		skip && NR<=10 { next }
		{ print }
	' "$MESON" > "${MESON}.tmp" && mv "${MESON}.tmp" "$MESON"
fi

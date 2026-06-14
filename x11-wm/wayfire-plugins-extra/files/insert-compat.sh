#!/bin/sh
# Insert FreeBSD compat shim into meson.build
# FreeBSD does not have linux/input-event-codes.h.
# Only insert if not already present (avoids duplication if already in tarball).
MESON="$1"
if grep -q "host_machine.system.*freebsd" "$MESON" 2>/dev/null; then
	echo "FreeBSD compat already present in $MESON, skipping."
	exit 0
fi
# Find the line that closes the project() call and insert compat after it.
# Anchor on the ')' that follows the 'project(' line (the closing paren of project()).
/usr/bin/sed -i.bak -e '/^project\(/,/^)$/{
	/^)$/a\
\
# FreeBSD compat: add compat/ to include path for linux/input-event-codes.h shim\
if host_machine.system() == '\''freebsd'\''\
	add_project_arguments('\''-I'\'' + meson.current_source_dir() + '\''/compat'\'', language: ['\''cpp'\'', '\''c'\''])\
endif
}' "$MESON"
rm -f "${MESON}.bak"

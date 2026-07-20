#!/bin/sh
# Insert FreeBSD compat shim into wayfire meson.build
# FreeBSD does not have linux/input-event-codes.h
MESON="$1"
/usr/bin/sed -i.bak -e '/^cpp = meson\.get_compiler.*$/a\
\
# FreeBSD compat: add compat/ to include path for linux/input-event-codes.h shim\
if host_machine.system() == '\''freebsd'\''\
	add_project_arguments('\''-I'\'' + meson.current_source_dir() + '\''/compat'\'', language: ['\''cpp'\'', '\''c'\''])\
endif' "$MESON"
rm -f "${MESON}.bak"

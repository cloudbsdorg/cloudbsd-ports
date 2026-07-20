#!/bin/sh
# Move git remote setup from before project() to after it.
# FreeBSD ports requires project() to be the first statement in meson.build.
MESON="$1"
TDIR=$(mktemp -d)
OUT="$TDIR/meson.build"
PREFIX_LINES=4
/usr/local/bin/python3.11 -c "
import sys
with open('${MESON}') as f:
    lines = f.readlines()

# Prefix = lines 1..4 (comment + run_command, no trailing blank)
prefix = lines[:${PREFIX_LINES}]
# Rest = lines 6 onwards (original lines after the blank line 5)
rest = lines[5:]

# Find the closing ')' of the project() call.
# It's the first line in rest that ends with ')' and whose previous line is indented (part of project)
proj_close = -1
for i, line in enumerate(rest):
    stripped = line.rstrip()
    # project() closes on a line with just ')' at the start of a line
    if stripped == ')':
        proj_close = i
        break

if proj_close < 0:
    print('ERROR: could not find project() closing )', file=sys.stderr)
    sys.exit(1)

with open('${OUT}', 'w') as f:
    # 1. Write lines up to and including project() closing )
    f.writelines(rest[:proj_close+1])
    # 2. A blank line separator
    f.write('\n')
    # 3. The git setup prefix (no trailing blank)
    f.writelines(prefix)
    # 4. The rest of the file
    f.writelines(rest[proj_close+1:])
"
mv "$OUT" "$MESON"
rm -rf "$TDIR"

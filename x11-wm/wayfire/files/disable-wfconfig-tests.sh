#!/bin/sh
# Disable tests in wf-config subproject (doctest not available in FreeBSD ports)
MESON="$1"
/usr/local/bin/python3.11 -c "
import sys
with open('${MESON}') as f:
    content = f.read()
content = content.replace(
    \"subproject('wf-config')\",
    \"subproject('wf-config', default_options: ['tests=disabled'])\"
)
with open('${MESON}', 'w') as f:
    f.write(content)
"

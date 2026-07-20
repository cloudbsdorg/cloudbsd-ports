#!/usr/bin/env python3
"""Patch data/meson.build to install PAM and xdg files to PREFIX/etc/ instead of /etc/."""
import sys
import re

meson = sys.argv[1]

with open(meson, 'r') as f:
    content = f.read()

# Replace PAM install_dir
content = re.sub(
    r"install_data\('wf-locker',\s*install_dir:\s*[^)]+\)",
    "install_data('wf-locker', install_dir: get_option('prefix') + '/etc/pam.d/')",
    content
)

# Replace xdg install_dir
content = re.sub(
    r"install_data\('xdpw/wayfire',\s*install_dir:\s*[^)]+\)",
    "install_data('xdpw/wayfire', install_dir: get_option('prefix') + '/etc/xdg/xdg-desktop-portal-wlr')",
    content
)

with open(meson, 'w') as f:
    f.write(content)

print(f"Patched {meson}")

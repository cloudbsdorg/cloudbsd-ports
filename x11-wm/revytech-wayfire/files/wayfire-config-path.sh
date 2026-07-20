#!/bin/sh
# Resolve Wayfire config: user prefs if present, else system default.
# shellcheck disable=SC2034
WAYFIRE_SYSTEM_CONFIG="${WAYFIRE_SYSTEM_CONFIG:-/usr/local/etc/wayfire/wayfire.ini}"
WAYFIRE_USER_CONFIG="${WAYFIRE_USER_CONFIG:-${HOME}/.config/wayfire.ini}"

if [ -n "${WAYFIRE_CONFIG_FILE:-}" ] && [ -f "${WAYFIRE_CONFIG_FILE}" ]; then
	printf '%s\n' "${WAYFIRE_CONFIG_FILE}"
elif [ -f "${WAYFIRE_USER_CONFIG}" ]; then
	printf '%s\n' "${WAYFIRE_USER_CONFIG}"
elif [ -f "${WAYFIRE_SYSTEM_CONFIG}" ]; then
	printf '%s\n' "${WAYFIRE_SYSTEM_CONFIG}"
else
	# Last resort: let wayfire use its built-in defaults
	printf '%s\n' "${WAYFIRE_USER_CONFIG}"
fi

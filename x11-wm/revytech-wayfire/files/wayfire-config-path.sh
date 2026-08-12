#!/bin/sh
# Resolve Wayfire config path.
#
# Hierarchy:
#   1) $WAYFIRE_CONFIG_FILE if set and exists
#   2) ~/.config/wayfire.ini (user prefs)
#   3) system default:
#        FreeBSD / PREFIX installs → /usr/local/etc/wayfire/wayfire.ini
#        Linux FHS               → /etc/wayfire/wayfire.ini
#        fallback                → /usr/local/etc/wayfire/wayfire.ini
#
# Never invent a nested session. Print one path and exit 0.
# shellcheck disable=SC2034

WAYFIRE_USER_CONFIG="${WAYFIRE_USER_CONFIG:-${HOME}/.config/wayfire.ini}"

if [ -z "${WAYFIRE_SYSTEM_CONFIG:-}" ]; then
  case "$(uname -s 2>/dev/null || echo unknown)" in
    Linux)
      if [ -f /etc/wayfire/wayfire.ini ]; then
        WAYFIRE_SYSTEM_CONFIG=/etc/wayfire/wayfire.ini
      elif [ -f /usr/local/etc/wayfire/wayfire.ini ]; then
        WAYFIRE_SYSTEM_CONFIG=/usr/local/etc/wayfire/wayfire.ini
      else
        WAYFIRE_SYSTEM_CONFIG=/etc/wayfire/wayfire.ini
      fi
      ;;
    FreeBSD|DragonFly|OpenBSD|NetBSD)
      WAYFIRE_SYSTEM_CONFIG=/usr/local/etc/wayfire/wayfire.ini
      ;;
    *)
      # Prefer PREFIX-style layout (FreeBSD ports / custom Linux PREFIX)
      if [ -f /usr/local/etc/wayfire/wayfire.ini ]; then
        WAYFIRE_SYSTEM_CONFIG=/usr/local/etc/wayfire/wayfire.ini
      else
        WAYFIRE_SYSTEM_CONFIG=/etc/wayfire/wayfire.ini
      fi
      ;;
  esac
fi

if [ -n "${WAYFIRE_CONFIG_FILE:-}" ] && [ -f "${WAYFIRE_CONFIG_FILE}" ]; then
  printf '%s\n' "${WAYFIRE_CONFIG_FILE}"
elif [ -f "${WAYFIRE_USER_CONFIG}" ]; then
  printf '%s\n' "${WAYFIRE_USER_CONFIG}"
elif [ -f "${WAYFIRE_SYSTEM_CONFIG}" ]; then
  printf '%s\n' "${WAYFIRE_SYSTEM_CONFIG}"
else
  # Last resort: report user path (wayfire creates/reads as needed)
  printf '%s\n' "${WAYFIRE_USER_CONFIG}"
fi

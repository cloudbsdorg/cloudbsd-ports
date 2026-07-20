/* SPDX-License-Identifier: MIT */
/*
 * FreeBSD compatibility shim for linux/input-event-codes.h
 *
 * FreeBSD does not provide the Linux kernel input event codes.
 * These are standard evdev values used throughout wayfire.
 *
 * Copyright (c) 2025 FreeBSD Foundation
 */

#ifndef _LINUX_INPUT_EVENT_CODES_H
#define _LINUX_INPUT_EVENT_CODES_H

#include <stdint.h>

/* Mouse buttons */
#define BTN_LEFT      0x110
#define BTN_RIGHT     0x111
#define BTN_MIDDLE    0x112
#define BTN_SIDE      0x113
#define BTN_EXTRA     0x114

/* Function keys */
#define KEY_F1        0x3B
#define KEY_F2        0x3C
#define KEY_F3        0x3D
#define KEY_F4        0x3E
#define KEY_F5        0x3F
#define KEY_F6        0x40
#define KEY_F7        0x41
#define KEY_F8        0x42
#define KEY_F9        0x43
#define KEY_F10       0x44
#define KEY_F11       0x45
#define KEY_F12       0x46

/* Basic keys */
#define KEY_ESC       0x01
#define KEY_BACKSPACE 0x0E
#define KEY_TAB       0x0F
#define KEY_ENTER     0x1C
#define KEY_LEFTSHIFT 0x2A
#define KEY_RIGHTSHIFT 0x36
#define KEY_LEFTCTRL  0x1D
#define KEY_RIGHTCTRL 0x9D
#define KEY_LEFTALT   0x38
#define KEY_RIGHTALT  0xB8
#define KEY_CAPS_LOCK 0x3A
#define KEY_SPACE     0x39

/* Arrow keys */
#define KEY_UP        0x67
#define KEY_DOWN      0x6C
#define KEY_LEFT      0x69
#define KEY_RIGHT     0x6A

/* WASD / vi-style navigation */
#define KEY_W         0x11
#define KEY_A         0x1E
#define KEY_S         0x1F
#define KEY_D         0x20
#define KEY_J         0x24
#define KEY_K         0x25
#define KEY_H         0x23
#define KEY_L         0x26

/* Misc */
#define KEY_INSERT    0xD2
#define KEY_DELETE    0xD3
#define KEY_HOME      0xC7
#define KEY_END       0xCF
#define KEY_PAGEUP    0xC9
#define KEY_PAGEDOWN  0xD1
#define KEY_MENU      0xDD

#endif /* _LINUX_INPUT_EVENT_CODES_H */

# REVYTECH Wayfire stack (CloudBSD / FreeBSD ports)

Separate, installable packaging of the **REVYTECH, Inc.** Wayfire desktop —
built from [revytechinc](https://github.com/revytechinc) **master/main** tips,
not stock FreeBSD `WayfireWM` ports.

Foundation: prior work on branch `wayfire-0.11.0` (revytechinc forks, FreeBSD
compat shims, submodule fetch scripts). This overlay **does not overwrite**
stock `x11-wm/wayfire` etc.; it adds parallel ports with a `revytech-` prefix
and `CONFLICTS_INSTALL` against stock packages.

## Ports

| Port | Source repo | Role |
|------|-------------|------|
| `devel/revytech-wf-config` | revytechinc/wf-config | config library |
| `x11-wm/revytech-wayfire` | revytechinc/wayfire | compositor |
| `x11-wm/revytech-wayfire-plugins-extra` | revytechinc/wayfire-plugins-extra | plugins |
| `x11/revytech-wf-shell` | revytechinc/wf-shell | panel, dock, **wf-settings** |
| `x11/revytech-wcm` | revytechinc/wcm | legacy config UI |
| `x11/revytech-wf-osk` | revytechinc/wf-osk | on-screen keyboard |
| `x11-wm/revytech-wayfire-desktop` | meta | full desktop deps |

Pins live in:

- [`VERSIONS`](VERSIONS) — human-readable SHAs  
- [`Makefile.inc`](Makefile.inc) — used by every port  

Policy: **latest is master/main**, not git tags. Refresh with:

```sh
GIT_ROOT=$HOME/git ./revytech/wayfire/scripts/refresh-pins.sh --fetch
./revytech/wayfire/install.sh --makesum
```

## Install (anyone with this tree)

```sh
git clone https://github.com/cloudbsdorg/cloudbsd-ports.git
cd cloudbsd-ports
git checkout revytech/wayfire-stack   # or main once merged

# Optional: remove stock wayfire stack if present
# doas pkg delete -y wayfire wf-shell wf-config wcm wayfire-plugins-extra

./revytech/wayfire/install.sh
```

What it does:

1. `pkg install` common build tools / libs  
2. `make makesum` if distinfo missing  
3. Builds each port in dependency order  
4. `make reinstall` / `install` via doas/sudo  

Meta only:

```sh
cd x11-wm/revytech-wayfire-desktop && make install clean
```

(Requires the leaf ports already present / indexable under `PORTSDIR`.)

## Every iteration: build + reinstall via pkg

**Policy:** each change ends with a package build and `pkg install -f`, not
`~/.local` prefix installs. Use:

```sh
export PORTSDIR=$PWD
./revytech/wayfire/scripts/build-and-pkg-install.sh
# or one component:
./revytech/wayfire/scripts/build-and-pkg-install.sh x11/revytech-wf-shell
```

That script stages, regenerates `pkg-plist`, builds `.pkg`, copies to
`~/.cache/revytech-packages/`, and `doas pkg install -fy`s it.

## Build a single component (manual)

```sh
export PORTSDIR=$PWD BATCH=yes
cd devel/revytech-wf-config
make makesum stage
make makeplist 2>/dev/null | grep -v '^/you' > pkg-plist
rm -f work/.PLIST.* work/.package_done*
make package
doas pkg install -fy work/pkg/*.pkg
```

## After install

1. `sysrc seatd_enable=YES && service seatd start`  
2. User in `video` group  
3. Session env: `XDG_RUNTIME_DIR`, `LIBSEAT_BACKEND=seatd`, `XDG_SESSION_TYPE=wayland`  
4. Config: `~/.config/wayfire.ini`, `~/.config/wf-shell.ini`, `~/.config/wf-shell/config.json`  
5. Binaries: `wayfire`, `wf-panel`, `wf-background`, `wf-dock`, `wf-settings`  

## Layout

```
revytech/wayfire/
  README.md
  VERSIONS
  Makefile.inc
  install.sh
  scripts/refresh-pins.sh
devel/revytech-wf-config/
x11-wm/revytech-wayfire/
x11-wm/revytech-wayfire-plugins-extra/
x11/revytech-wf-shell/
x11/revytech-wcm/
x11/revytech-wf-osk/
x11-wm/revytech-wayfire-desktop/
```

## Related local clones

Expected under `~/git` for pin refresh:

wayfire, wayfire-plugins-extra, wf-config, wf-shell, wcm, wf-utils, wf-touch,
wf-json, wf-osk, wlroots (optional; compositor defaults to ports `wlroots020`).

## License

Upstream components are MIT (Wayfire stack). Port scaffolding is for CloudBSD /
REVYTECH packaging use.

## Development loop (required)

**Every code change must end with a package rebuild and reinstall via pkg:**

```sh
./revytech/wayfire/scripts/build-and-pkg-install.sh x11/revytech-wf-shell
# or the full stack:
./revytech/wayfire/install.sh
```

This runs `make stage` + `doas make reinstall` so the installed system always
matches the ports tree and packages are registered with `pkg`.

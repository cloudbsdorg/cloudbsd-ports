#!/bin/sh
# Fetch wf-json git submodule since GitHub tarball doesn't include submodule contents
# wf-json is a git submodule at WayfireWM/wf-json with commit 70039e13cdeaebd8ec498ed30bf5ab91c2e313ec
WRKSRC="$1"
SUBMODULE_DIR="${WRKSRC}/subprojects/wf-json"

if [ -d "${SUBMODULE_DIR}" ] && [ ! -f "${SUBMODULE_DIR}/meson.build" ]; then
    echo "Fetching wf-json submodule..."
    cd "${SUBMODULE_DIR}"
    git init -q
    git remote add origin https://github.com/WayfireWM/wf-json
    git fetch -q --depth 1 origin 70039e13cdeaebd8ec498ed30bf5ab91c2e313ec
    git checkout -q 70039e13cdeaebd8ec498ed30bf5ab91c2e313ec
    echo "wf-json submodule fetched successfully"
fi

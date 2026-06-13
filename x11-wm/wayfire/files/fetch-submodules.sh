#!/bin/sh
# Fetch git submodules missing from the GitHub tarball.
# GitHub tarballs don't include submodule contents (mode 160000).
# Submodule commit references at wayfire commit 886735908d7d6fcd8d58ed2885964f7abf534ef2
WRKSRC="$1"

fetch_submodule() {
    local name="$1"
    local url="$2"
    local commit="$3"
    local srcdir="${WRKSRC}/subprojects/${name}"

    if [ ! -f "${srcdir}/meson.build" ]; then
        echo "Fetching ${name} submodule (commit ${commit})..."
        rm -rf "${srcdir}"
        mkdir -p "${srcdir}"
        git init -q "${srcdir}"
        git -C "${srcdir}" remote add origin "${url}"
        git -C "${srcdir}" fetch -q --depth 1 origin "${commit}"
        git -C "${srcdir}" checkout -q "${commit}"
        echo "${name} fetched successfully"
    else
        echo "${name} already present, skipping"
    fi
}

fetch_submodule "wf-json"   "https://github.com/WayfireWM/wf-json"   "70039e13cdeaebd8ec498ed30bf5ab91c2e313ec"
fetch_submodule "wf-config" "https://github.com/WayfireWM/wf-config" "a2051f5d131a23acdcd96bfeb509d01cf57139ec"
fetch_submodule "wf-utils"  "https://github.com/WayfireWM/wf-utils"  "329c3ff01724d82947f61c45332f75d3534e8454"
fetch_submodule "wf-touch"  "https://github.com/WayfireWM/wf-touch"  "093d8943df03cc8a2667990a065513c1bf2b57e0"

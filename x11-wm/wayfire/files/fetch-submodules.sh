#!/bin/sh
# Fetch git submodules missing from the GitHub tarball.
# GitHub tarballs don't include submodule contents (mode 160000).
# Submodule commit references at wayfire commit v0.11.0-revytech.1 (d55960deb39ed3ee3115a3b0a86079e1cdb4ff2b)
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

fetch_submodule "wf-json"   "https://github.com/revytechinc/wf-json.git"   "70039e13cdeaebd8ec498ed30bf5ab91c2e313ec"
fetch_submodule "wf-config" "https://github.com/revytechinc/wf-config.git" "ccfe77ce6386eab76465be5d4cb5fcfd962faca2"
fetch_submodule "wf-utils"  "https://github.com/revytechinc/wf-utils.git"  "329c3ff01724d82947f61c45332f75d3534e8454"
fetch_submodule "wf-touch"  "https://github.com/revytechinc/wf-touch.git"  "093d8943df03cc8a2667990a065513c1bf2b57e0"
